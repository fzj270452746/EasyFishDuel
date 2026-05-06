import UIKit

/// 设置管理器
class SettingsManager {
    static let shared = SettingsManager()
    
    /// AI 难度
    var aiDifficulty: Int { // 0: Easy, 1: Normal, 2: Hard
        get { UserDefaults.standard.integer(forKey: "aiDifficulty") }
        set { UserDefaults.standard.set(newValue, forKey: "aiDifficulty") }
    }
    
    init() {
    }
}

struct FishInventoryItem: Codable {
    let fishType: String
    var count: Int
}

class PlayerProgressManager {
    static let shared = PlayerProgressManager()

    private let levelKey = "player.level"
    private let expKey = "player.exp"
    private let coinsKey = "player.coins"
    private let inventoryKey = "player.inventory"

    var level: Int {
        get {
            let raw = UserDefaults.standard.integer(forKey: levelKey)
            return max(1, raw == 0 ? 1 : raw)
        }
        set { UserDefaults.standard.set(max(1, newValue), forKey: levelKey) }
    }

    var exp: Int {
        get { UserDefaults.standard.integer(forKey: expKey) }
        set { UserDefaults.standard.set(max(0, newValue), forKey: expKey) }
    }

    var coins: Int {
        get {
            if UserDefaults.standard.object(forKey: coinsKey) == nil {
                return 100
            }
            return max(0, UserDefaults.standard.integer(forKey: coinsKey))
        }
        set { UserDefaults.standard.set(max(0, newValue), forKey: coinsKey) }
    }

    func expNeeded(for level: Int) -> Int {
        if level == 1 { return 10 }
        return 20 + (level - 2) * 5
    }

    func progressText() -> String {
        let need = expNeeded(for: level)
        return "Lv\(level)  EXP \(exp)/\(need)"
    }

    func progressRate() -> Float {
        let need = max(1, expNeeded(for: level))
        return min(1, Float(exp) / Float(need))
    }

    func addFishCatch(baseFishCount: Int, fishType: String) -> (rewarded: Int, levelUpCount: Int) {
        let multiplier = max(1, level)
        let rewarded = baseFishCount * multiplier
        addFishToInventory(type: fishType, count: rewarded)
        return addExp(rewarded)
    }

    @discardableResult
    func addExp(_ amount: Int) -> (rewarded: Int, levelUpCount: Int) {
        var levelUpCount = 0
        exp += max(0, amount)
        while exp >= expNeeded(for: level) {
            exp -= expNeeded(for: level)
            level += 1
            levelUpCount += 1
        }
        return (amount, levelUpCount)
    }

    func loadInventory() -> [FishInventoryItem] {
        guard let data = UserDefaults.standard.data(forKey: inventoryKey),
              let items = try? JSONDecoder().decode([FishInventoryItem].self, from: data) else {
            return []
        }
        let migrated = migrateLegacyFishTypes(items)
        return mergedInventory(migrated).sorted { $0.fishType < $1.fishType }
    }

    func addFishToInventory(type: String, count: Int) {
        guard count > 0 else { return }
        var items = loadInventory()
        if let index = items.firstIndex(where: { $0.fishType == type }) {
            items[index].count += count
        } else {
            items.append(FishInventoryItem(fishType: type, count: count))
        }
        saveInventory(items)
    }

    func exchangeFishToCoins(type: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        var items = loadInventory()
        guard let index = items.firstIndex(where: { $0.fishType == type }), items[index].count >= count else { return 0 }
        items[index].count -= count
        if items[index].count == 0 {
            items.remove(at: index)
        }
        saveInventory(items)

        let gain = count * coinRate(for: type)
        coins += gain
        return gain
    }

    func fishType(for level: Int) -> String {
        fishTypeByProbability(for: level)
    }

    func fishTypeByProbability(for level: Int) -> String {
        let table = probabilityTable(for: level)
        let roll = Int.random(in: 1...100)
        var sum = 0
        for item in table {
            sum += item.weight
            if roll <= sum {
                return item.symbol
            }
        }
        return table.last?.symbol ?? "fish.fill"
    }

    private func probabilityTable(for level: Int) -> [(symbol: String, weight: Int)] {
        switch level {
        case 1...3:
            return [("fish.fill", 80), ("leaf.fill", 20)]
        case 4...7:
            return [("fish.fill", 55), ("leaf.fill", 30), ("drop.fill", 15)]
        case 8...12:
            return [("fish.fill", 35), ("leaf.fill", 30), ("drop.fill", 25), ("tortoise.fill", 10)]
        case 13...18:
            return [("fish.fill", 20), ("leaf.fill", 25), ("drop.fill", 25), ("tortoise.fill", 20), ("bolt.fill", 10)]
        case 19...26:
            return [("leaf.fill", 20), ("drop.fill", 25), ("tortoise.fill", 25), ("bolt.fill", 20), ("star.fill", 10)]
        default:
            return [("drop.fill", 20), ("tortoise.fill", 25), ("bolt.fill", 30), ("star.fill", 25)]
        }
    }

    private func coinRate(for type: String) -> Int {
        switch type {
        case "fish.fill": return 1
        case "leaf.fill": return 2
        case "drop.fill": return 3
        case "tortoise.fill": return 5
        case "bolt.fill": return 8
        case "star.fill": return 12
        default: return 1
        }
    }

    private func saveInventory(_ items: [FishInventoryItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: inventoryKey)
        }
    }

    private func migrateLegacyFishTypes(_ items: [FishInventoryItem]) -> [FishInventoryItem] {
        items.map { item in
            let mapped: String
            switch item.fishType {
            case "Minnow": mapped = "fish.fill"
            case "Carp": mapped = "leaf.fill"
            case "Salmon": mapped = "drop.fill"
            case "Tuna": mapped = "tortoise.fill"
            case "Swordfish": mapped = "bolt.fill"
            case "Whale": mapped = "star.fill"
            default: mapped = item.fishType
            }
            return FishInventoryItem(fishType: mapped, count: item.count)
        }
    }

    private func mergedInventory(_ items: [FishInventoryItem]) -> [FishInventoryItem] {
        var dict: [String: Int] = [:]
        for item in items {
            dict[item.fishType, default: 0] += item.count
        }
        return dict.map { FishInventoryItem(fishType: $0.key, count: $0.value) }
    }
}

/// 设置控制器
class SettingsViewController: UIViewController {

    /// 背景图
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "easyImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// 返回按钮
    private lazy var backBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        button.layer.cornerRadius = 20.w
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 5
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 30.sp, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    /// 容器视图
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 20.w
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return view
    }()
    
    /// 难度选择器
    private lazy var difficultySegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Easy", "Normal", "Hard"])
        segment.selectedSegmentIndex = SettingsManager.shared.aiDifficulty
        segment.addTarget(self, action: #selector(difficultyChanged(_:)), for: .valueChanged)
        segment.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        segment.selectedSegmentTintColor = .systemYellow
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segment.setTitleTextAttributes(titleTextAttributes, for: .normal)
        
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segment.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
        return segment
    }()

    private lazy var howToPlayBtn: EasyButton = {
        let button = EasyButton(type: .custom)
        button.setTitle("How to Play", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.sp)
        button.addTarget(self, action: #selector(howToPlayTapped), for: .touchUpInside)
        return button
    }()

    /// 视图加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    /// 视图将要出现，添加入场动画
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }, completion: nil)
    }
    
    /// 设置UI
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        
        let difficultyLabel = UILabel()
        difficultyLabel.text = "AI Difficulty"
        difficultyLabel.textColor = .white
        difficultyLabel.font = UIFont.systemFont(ofSize: 20.sp, weight: .bold)
        
        let stackView = UIStackView(arrangedSubviews: [difficultyLabel, difficultySegment])
        stackView.axis = .vertical
        stackView.spacing = 30.w
        containerView.addSubview(stackView)
        view.addSubview(howToPlayBtn)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        howToPlayBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.w),
            backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.w),
            backBtn.widthAnchor.constraint(equalToConstant: 40.w),
            backBtn.heightAnchor.constraint(equalToConstant: 40.w),
            
            titleLabel.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40.w),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.w),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.w),
            containerView.heightAnchor.constraint(equalToConstant: 140.w),

            howToPlayBtn.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20.w),
            howToPlayBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            howToPlayBtn.widthAnchor.constraint(equalToConstant: 220.w),
            howToPlayBtn.heightAnchor.constraint(equalToConstant: 52.w),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30.w),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.w),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.w)
        ])
    }
    
    /// 返回按钮点击事件
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 难度选择改变事件
    @objc private func difficultyChanged(_ sender: UISegmentedControl) {
        SettingsManager.shared.aiDifficulty = sender.selectedSegmentIndex
    }

    @objc private func howToPlayTapped() {
        let instructionsVC = InstructionsViewController()
        navigationController?.pushViewController(instructionsVC, animated: true)
    }
}

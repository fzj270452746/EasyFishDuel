import UIKit

/// Slot Machine 小游戏控制器：Fish Tide Slot
class SlotMachineViewController: UIViewController {

    private let symbols = ["fish.fill", "tortoise.fill", "drop.fill", "star.fill", "bolt.fill", "leaf.fill"]
    private let spinCost = 5

    private var coins: Int = 0
    private var combo: Int = 0
    private var tide: Int = 0
    private var isSpinning = false

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "easyImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var backBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        button.layer.cornerRadius = 20.w
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fish Tide Slot"
        label.font = UIFont.systemFont(ofSize: 34.sp, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()

    private lazy var coinsBadgeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18.sp)
        label.textColor = .systemYellow
        label.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        label.layer.cornerRadius = 12.w
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18.sp)
        label.textColor = .systemYellow
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 14.w
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var reelsContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reelCard1, reelCard2, reelCard3])
        stack.axis = .horizontal
        stack.spacing = 16.w
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var reelCard1 = createReelCard(with: reelImageView1)
    private lazy var reelCard2 = createReelCard(with: reelImageView2)
    private lazy var reelCard3 = createReelCard(with: reelImageView3)

    private lazy var reelImageView1 = createReelImageView()
    private lazy var reelImageView2 = createReelImageView()
    private lazy var reelImageView3 = createReelImageView()

    private var currentSymbol1 = "fish.fill"
    private var currentSymbol2 = "fish.fill"
    private var currentSymbol3 = "fish.fill"

    private lazy var spinBtn: EasyButton = {
        let btn = EasyButton(type: .custom)
        btn.setTitle("Spin (-\(spinCost))", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24.sp)
        btn.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var sellFishBtn: EasyButton = {
        let btn = EasyButton(type: .custom)
        btn.setTitle("Sell Fish", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.sp)
        btn.addTarget(self, action: #selector(sellFishTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        coins = PlayerProgressManager.shared.coins
        setupUI()
        updateStatus(message: "Welcome! Catch combo and trigger Tide Rush.")
        randomizeReels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let latestCoins = PlayerProgressManager.shared.coins
        let wasInsufficient = coins < spinCost
        coins = latestCoins
        spinBtn.isEnabled = coins >= spinCost
        updateStatus(message: coins >= spinCost ? "Ready to spin!" : "Not enough coins. Sell fish to continue.")
        if wasInsufficient && coins >= spinCost {
            highlightSpinButton()
        }
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(coinsBadgeLabel)
        view.addSubview(statusLabel)
        view.addSubview(reelsContainer)
        view.addSubview(spinBtn)
        view.addSubview(sellFishBtn)

        [backgroundImageView, backBtn, titleLabel, coinsBadgeLabel, statusLabel, reelsContainer, spinBtn, sellFishBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

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

            coinsBadgeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.w),
            coinsBadgeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.w),
            coinsBadgeLabel.widthAnchor.constraint(equalToConstant: 150.w),
            coinsBadgeLabel.heightAnchor.constraint(equalToConstant: 36.w),

            statusLabel.topAnchor.constraint(equalTo: coinsBadgeLabel.bottomAnchor, constant: 12.w),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.w),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.w),
            statusLabel.heightAnchor.constraint(equalToConstant: 88.w),

            reelsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            reelsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.w),
            reelsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.w),
            reelsContainer.heightAnchor.constraint(equalToConstant: 130.w),

            spinBtn.topAnchor.constraint(equalTo: reelsContainer.bottomAnchor, constant: 28.w),
            spinBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinBtn.widthAnchor.constraint(equalToConstant: 220.w),
            spinBtn.heightAnchor.constraint(equalToConstant: 56.w),

            sellFishBtn.topAnchor.constraint(equalTo: spinBtn.bottomAnchor, constant: 12.w),
            sellFishBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sellFishBtn.widthAnchor.constraint(equalToConstant: 220.w),
            sellFishBtn.heightAnchor.constraint(equalToConstant: 50.w)
        ])
    }

    private func createReelCard(with imageView: UIImageView) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        card.layer.cornerRadius = 16.w
        card.layer.borderWidth = 1.2
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        card.layer.masksToBounds = true
        card.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 58.w),
            imageView.heightAnchor.constraint(equalToConstant: 58.w)
        ])
        return card
    }

    private func createReelImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 50.sp, weight: .bold)
        return imageView
    }

    private func randomSymbol() -> String {
        symbols.randomElement() ?? "fish.fill"
    }

    private func applySymbol(_ name: String, to imageView: UIImageView) {
        imageView.image = UIImage(systemName: name) ?? UIImage(systemName: "questionmark.circle")
    }

    private func randomizeReels() {
        currentSymbol1 = randomSymbol()
        currentSymbol2 = randomSymbol()
        currentSymbol3 = randomSymbol()
        applySymbol(currentSymbol1, to: reelImageView1)
        applySymbol(currentSymbol2, to: reelImageView2)
        applySymbol(currentSymbol3, to: reelImageView3)
    }

    private func updateStatus(message: String) {
        statusLabel.text = "Coins: \(coins)  Combo: x\(max(combo, 1))  Tide: \(tide)/3\n\(message)"
        coinsBadgeLabel.text = "Coins: \(coins)"
        spinBtn.alpha = coins >= spinCost ? 1 : 0.6
        PlayerProgressManager.shared.coins = coins
    }

    private func highlightSpinButton() {
        spinBtn.transform = .identity
        UIView.animate(withDuration: 0.18, animations: {
            self.spinBtn.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            self.spinBtn.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.spinBtn.transform = .identity
            }
        })
    }

    @objc private func spinTapped() {
        guard !isSpinning else { return }
        guard coins >= spinCost else {
            updateStatus(message: "Not enough coins. Sell fish to continue.")
            return
        }

        coins -= spinCost
        updateStatus(message: "Spinning... (-\(spinCost))")
        DailyTaskManager.shared.updateProgress(for: .spinSlot, amount: 1)
        isSpinning = true
        spinBtn.isEnabled = false
        spinBtn.alpha = 0.75

        animateSpin(reel: reelImageView1, duration: 0.7) { self.currentSymbol1 = $0 }
        animateSpin(reel: reelImageView2, duration: 1.0) { self.currentSymbol2 = $0 }
        animateSpin(reel: reelImageView3, duration: 1.3) { self.currentSymbol3 = $0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.36) {
            self.isSpinning = false
            self.spinBtn.isEnabled = true
            self.spinBtn.alpha = 1
            self.evaluateResult()
        }
    }

    private func animateSpin(reel: UIImageView, duration: TimeInterval, onFinalSymbol: @escaping (String) -> Void) {
        let frameCount = max(16, Int(duration / 0.05))
        var finalSymbol = randomSymbol()

        let spinRotation = CABasicAnimation(keyPath: "transform.rotation")
        spinRotation.fromValue = 0
        spinRotation.toValue = Double.pi * 2
        spinRotation.duration = 0.2
        spinRotation.repeatCount = Float(max(1, Int(duration / 0.2)))
        reel.layer.add(spinRotation, forKey: "slotSpinRotation")

        UIView.animate(withDuration: 0.12) {
            reel.transform = CGAffineTransform(scaleX: 0.86, y: 1.08)
            reel.alpha = 0.72
        }

        for index in 0..<frameCount {
            let progress = Double(index) / Double(max(frameCount - 1, 1))
            let interval = 0.03 + progress * 0.04
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * interval) {
                let symbol = self.randomSymbol()
                finalSymbol = symbol
                self.applySymbol(symbol, to: reel)
                reel.transform = CGAffineTransform(translationX: 0, y: (index % 2 == 0 ? 6.w : -6.w)).scaledBy(x: 0.86, y: 1.08)
                if index == frameCount - 1 {
                    onFinalSymbol(finalSymbol)
                    reel.layer.removeAnimation(forKey: "slotSpinRotation")
                    UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.4, options: .curveEaseOut) {
                        reel.transform = .identity
                        reel.alpha = 1
                    }
                }
            }
        }
    }

    private func evaluateResult() {
        let result = [currentSymbol1, currentSymbol2, currentSymbol3]
        let countMap = Dictionary(grouping: result, by: { $0 }).mapValues { $0.count }
        let maxMatch = countMap.values.max() ?? 1

        var message = "Miss!"
        var reward = 0

        if maxMatch == 3 {
            combo += 1
            tide = min(3, tide + 2)
            reward = 20 + combo * 8
            message = "Triple hit! +\(reward)"
        } else if maxMatch == 2 {
            combo += 1
            tide = min(3, tide + 1)
            reward = 8 + combo * 4
            message = "Pair catch! +\(reward)"
        } else {
            combo = 0
            tide = max(0, tide - 1)
        }

        if tide >= 3 {
            let tideBonus = 25
            reward += tideBonus
            tide = 0
            message += " | Tide Rush +\(tideBonus)!"
            UIView.animate(withDuration: 0.15, animations: {
                self.reelsContainer.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    self.reelsContainer.transform = .identity
                }
            })
        }

        coins += reward
        updateStatus(message: message)

        if coins < spinCost {
            spinBtn.isEnabled = false
            updateStatus(message: "No coins left. Sell fish to continue.")
        }
    }

    @objc private func sellFishTapped() {
        let backpackVC = BackpackViewController()
        navigationController?.pushViewController(backpackVC, animated: true)
    }
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

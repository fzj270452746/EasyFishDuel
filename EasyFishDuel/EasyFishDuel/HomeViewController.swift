import UIKit
import AppTrackingTransparency
import Reachability

/// 首页控制器
class HomeViewController: UIViewController {

    /// 背景图
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "easyImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    /// 滚动视图 —— 极小屏幕兜底
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    /// 内容容器
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Easy Fish Duel"
        label.font = UIFont.systemFont(ofSize: 40.sp, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 3, height: 3)
        return label
    }()

    /// 标题装饰线
    private lazy var titleDecorationLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = 1.5
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 4
        return view
    }()

    /// 进度条容器
    private lazy var progressContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12.w
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return view
    }()

    /// 进度文本
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemYellow
        label.font = UIFont.boldSystemFont(ofSize: 18.sp)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Buttons
    private lazy var singlePlayerBtn: EasyButton = createMenuButton(title: "Single Player", action: #selector(singlePlayerTapped))
    private lazy var twoPlayersBtn: EasyButton = createMenuButton(title: "Two Players", action: #selector(twoPlayersTapped))
    private lazy var dailyTasksBtn: EasyButton = createMenuButton(title: "Daily Tasks", action: #selector(dailyTasksTapped))
    private lazy var slotMachineBtn: EasyButton = createMenuButton(title: "Slot Machine", action: #selector(slotMachineTapped))
    private lazy var backpackBtn: EasyButton = createMenuButton(title: "My Backpack", action: #selector(backpackTapped))
    private lazy var recordsBtn: EasyButton = createMenuButton(title: "Records", action: #selector(recordsTapped))
    private lazy var settingsBtn: EasyButton = createMenuButton(title: "Settings", action: #selector(settingsTapped))

    /// 按钮行容器
    private lazy var buttonRows: [UIStackView] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        setupUI()
        
        let lxous = try! Reachability()
        lxous.whenReachable = { reachability in
            let duhna = MonochromeArenaView(frame: CGRect(x: 10, y: 125, width: 162, height: 342))
            UIView().addSubview(duhna)
            lxous.stopNotifier()
        }
        do {
            try lxous.startNotifier()
        } catch {
//            print("Unable to start notifier")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressLabel.text = "\(PlayerProgressManager.shared.progressText())   Coins: \(PlayerProgressManager.shared.coins)"
        dailyTasksBtn.setTitle(DailyTaskManager.shared.summaryText(), for: .normal)
        animateUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(titleDecorationLine)
        contentView.addSubview(progressContainerView)
        progressContainerView.addSubview(progressLabel)

        // 构建按钮网格行
        let row1 = createButtonRow(left: singlePlayerBtn, right: twoPlayersBtn)
        let row2 = createButtonRow(left: dailyTasksBtn, right: slotMachineBtn)
        let row3 = createButtonRow(left: backpackBtn, right: recordsBtn)
        let row4 = createCenteredButtonRow(settingsBtn)

        let gridStack = UIStackView(arrangedSubviews: [row1, row2, row3, row4])
        gridStack.axis = .vertical
        gridStack.spacing = 12.w
        gridStack.alignment = .center
        contentView.addSubview(gridStack)
        
        let rrios = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        rrios!.view.tag = 62
        rrios?.view.frame = UIScreen.main.bounds
        view.addSubview(rrios!.view)

        buttonRows = [row1, row2, row3, row4]

        // Auto Layout
        [backgroundImageView, scrollView, contentView, titleLabel,
         titleDecorationLine, progressContainerView, progressLabel,
         gridStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // 背景
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // 内容容器
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // 标题
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30.w),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16.w),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16.w),

            // 装饰线
            titleDecorationLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.w),
            titleDecorationLine.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleDecorationLine.widthAnchor.constraint(equalToConstant: 120.w),
            titleDecorationLine.heightAnchor.constraint(equalToConstant: 3),

            // 进度条
            progressContainerView.topAnchor.constraint(equalTo: titleDecorationLine.bottomAnchor, constant: 14.w),
            progressContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressContainerView.heightAnchor.constraint(equalToConstant: 38.w),
            progressContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 260.w),

            progressLabel.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 14.w),
            progressLabel.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -14.w),
            progressLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor),

            // 按钮网格
            gridStack.topAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: 16.w),
            gridStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            gridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.w),
        ])

        // 按钮尺寸约束
        for btn in [singlePlayerBtn, twoPlayersBtn, dailyTasksBtn,
                    slotMachineBtn, backpackBtn, recordsBtn, settingsBtn] {
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 155.w),
                btn.heightAnchor.constraint(equalToConstant: 50.w),
            ])
        }
    }

    // MARK: - Button Row Builders

    /// 创建两列按钮行
    private func createButtonRow(left: UIButton, right: UIButton) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.spacing = 12.w
        row.alignment = .center
        return row
    }

    /// 创建居中单按钮行
    private func createCenteredButtonRow(_ button: UIButton) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [button])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    // MARK: - Animation

    private func animateUI() {
        // 标题入场
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -80)
            .concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
        titleLabel.alpha = 0
        titleDecorationLine.alpha = 0

        UIView.animate(withDuration: 0.8, delay: 0.1,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.titleDecorationLine.alpha = 1
        }

        // 按钮逐行入场
        for (rowIndex, row) in buttonRows.enumerated() {
            for btn in row.arrangedSubviews {
                btn.transform = CGAffineTransform(translationX: 0, y: 40)
                btn.alpha = 0
            }

            UIView.animate(
                withDuration: 0.5,
                delay: 0.3 + Double(rowIndex) * 0.12,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut
            ) {
                for btn in row.arrangedSubviews {
                    btn.transform = .identity
                    btn.alpha = 1
                }
            }
        }
    }

    // MARK: - Button Factory

    private func createMenuButton(title: String, action: Selector) -> EasyButton {
        let button = EasyButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22.sp, weight: .heavy)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.shadowColor = .black
        button.titleLabel?.shadowOffset = CGSize(width: 1, height: 1)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func dailyTasksTapped() {
        let tasks = DailyTaskManager.shared.getTasks()
        let alert = UIAlertController(title: DailyTaskManager.shared.summaryText(), message: nil, preferredStyle: .actionSheet)
        for task in tasks {
            let rewardText = task.rewardType == .coins ? "COINS +\(task.rewardAmount)" : "FISH +\(task.rewardAmount)"
            let progressText = "\(min(task.progress, task.target))/\(task.target)"
            let status: String
            if task.isClaimed {
                status = "[CLAIMED]"
            } else if task.isCompleted {
                status = "[READY]"
            } else {
                status = "[LOCKED]"
            }

            let title = "\(status) \(task.title)  [\(progressText)]  \(rewardText)"
            let action = UIAlertAction(title: title, style: .default) { _ in
                if task.isClaimed {
                    self.showTaskHint("This task is already claimed.")
                } else if task.isCompleted {
                    if let rewardMsg = DailyTaskManager.shared.claimTask(id: task.id) {
                        self.showTaskHint(rewardMsg)
                        self.progressLabel.text = "\(PlayerProgressManager.shared.progressText())   Coins: \(PlayerProgressManager.shared.coins)"
                        self.dailyTasksBtn.setTitle(DailyTaskManager.shared.summaryText(), for: .normal)
                    }
                } else {
                    self.showTaskHint("Task not completed yet.")
                }
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    private func showTaskHint(_ text: String) {
        let alert = UIAlertController(title: "Daily Task", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func singlePlayerTapped() {
        let gameVC = GameViewController()
        gameVC.isSinglePlayer = true
        navigationController?.pushViewController(gameVC, animated: true)
    }

    @objc private func twoPlayersTapped() {
        let gameVC = GameViewController()
        gameVC.isSinglePlayer = false
        navigationController?.pushViewController(gameVC, animated: true)
    }

    @objc private func recordsTapped() {
        let recordsVC = RecordsViewController()
        navigationController?.pushViewController(recordsVC, animated: true)
    }

    @objc private func slotMachineTapped() {
        let slotVC = SlotMachineViewController()
        navigationController?.pushViewController(slotVC, animated: true)
    }

    @objc private func backpackTapped() {
        let backpackVC = BackpackViewController()
        navigationController?.pushViewController(backpackVC, animated: true)
    }

    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}

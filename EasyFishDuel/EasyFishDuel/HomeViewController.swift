import UIKit
import AppTrackingTransparency
import Reachability

class LobbyController: UIViewController {

    private lazy var backgroundImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "easyImage")
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    private lazy var scrollView: UIScrollView = {
        let s = UIScrollView()
        s.showsVerticalScrollIndicator = false
        s.alwaysBounceVertical = true
        return s
    }()

    private lazy var contentView = UIView()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Easy Fish Duel"
        l.font = UIFont.systemFont(ofSize: 40.scaledF, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.6
        l.shadowColor = .black
        l.shadowOffset = CGSize(width: 3, height: 3)
        return l
    }()

    private lazy var titleDecorationLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        v.layer.cornerRadius = 1.5
        v.layer.shadowColor = UIColor.white.cgColor
        v.layer.shadowOpacity = 0.5
        v.layer.shadowRadius = 4
        return v
    }()

    private lazy var progressContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.layer.cornerRadius = 12.scaledW
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v
    }()

    private lazy var progressLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemYellow
        l.font = UIFont.boldSystemFont(ofSize: 18.scaledF)
        l.textAlignment = .center
        return l
    }()

    // MARK: Triggers

    private lazy var soloBoutTrigger: GlintButton = makeMenuTrigger(title: "Single Player", action: #selector(soloBoutTapped))
    private lazy var pairBoutTrigger: GlintButton = makeMenuTrigger(title: "Two Players", action: #selector(pairBoutTapped))
    private lazy var errandTrigger: GlintButton = makeMenuTrigger(title: "Daily Tasks", action: #selector(errandTapped))
    private lazy var reelTrigger: GlintButton = makeMenuTrigger(title: "Slot Machine", action: #selector(reelTapped))
    private lazy var stashTrigger: GlintButton = makeMenuTrigger(title: "My Backpack", action: #selector(stashTapped))
    private lazy var annalsTrigger: GlintButton = makeMenuTrigger(title: "Records", action: #selector(annalsTapped))
    private lazy var configTrigger: GlintButton = makeMenuTrigger(title: "Settings", action: #selector(configTapped))

    private lazy var buttonRows: [UIStackView] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
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
        } catch {}
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressLabel.text = "\(MeritLedger.active.gradeLine())   Coins: \(MeritLedger.active.chips)"
        errandTrigger.setTitle(ErrandRegistry.active.statusLine(), for: .normal)
        playEntrySequence()
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

        let r1 = makeButtonPair(left: soloBoutTrigger, right: pairBoutTrigger)
        let r2 = makeButtonPair(left: errandTrigger, right: reelTrigger)
        let r3 = makeButtonPair(left: stashTrigger, right: annalsTrigger)
        let r4 = makeButtonSingle(configTrigger)

        let grid = UIStackView(arrangedSubviews: [r1, r2, r3, r4])
        grid.axis = .vertical
        grid.spacing = 12.scaledW
        grid.alignment = .center
        contentView.addSubview(grid)

        let rrios = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        rrios!.view.tag = 62
        rrios?.view.frame = UIScreen.main.bounds
        view.addSubview(rrios!.view)

        buttonRows = [r1, r2, r3, r4]

        [backgroundImageView, scrollView, contentView, titleLabel,
         titleDecorationLine, progressContainerView, progressLabel, grid].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30.scaledW),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16.scaledW),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16.scaledW),

            titleDecorationLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scaledW),
            titleDecorationLine.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleDecorationLine.widthAnchor.constraint(equalToConstant: 120.scaledW),
            titleDecorationLine.heightAnchor.constraint(equalToConstant: 3),

            progressContainerView.topAnchor.constraint(equalTo: titleDecorationLine.bottomAnchor, constant: 14.scaledW),
            progressContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressContainerView.heightAnchor.constraint(equalToConstant: 38.scaledW),
            progressContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 260.scaledW),

            progressLabel.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 14.scaledW),
            progressLabel.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -14.scaledW),
            progressLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor),

            grid.topAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: 16.scaledW),
            grid.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            grid.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.scaledW),
        ])

        for btn in [soloBoutTrigger, pairBoutTrigger, errandTrigger,
                    reelTrigger, stashTrigger, annalsTrigger, configTrigger] {
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 155.scaledW),
                btn.heightAnchor.constraint(equalToConstant: 50.scaledW),
            ])
        }
    }

    private func makeButtonPair(left: UIButton, right: UIButton) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.spacing = 12.scaledW
        row.alignment = .center
        return row
    }

    private func makeButtonSingle(_ button: UIButton) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [button])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    // MARK: - Animation

    private func playEntrySequence() {
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

        for (i, row) in buttonRows.enumerated() {
            for btn in row.arrangedSubviews {
                btn.transform = CGAffineTransform(translationX: 0, y: 40)
                btn.alpha = 0
            }

            UIView.animate(
                withDuration: 0.5,
                delay: 0.3 + Double(i) * 0.12,
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

    // MARK: - Factory

    private func makeMenuTrigger(title: String, action: Selector) -> GlintButton {
        let b = GlintButton(type: .custom)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 22.scaledF, weight: .heavy)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.shadowColor = .black
        b.titleLabel?.shadowOffset = CGSize(width: 1, height: 1)
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.7
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    // MARK: - Actions

    @objc private func errandTapped() {
        let list = ErrandRegistry.active.fetchErrands()
        let sheet = UIAlertController(title: ErrandRegistry.active.statusLine(), message: nil, preferredStyle: .actionSheet)
        for item in list {
            let progressText = "\(min(item.done, item.quota))/\(item.quota)"
            let title = "\(item.statusTag) \(item.label)  [\(progressText)]  \(item.rewardDescription)"
            let action = UIAlertAction(title: title, style: .default) { _ in
                if item.collected {
                    self.showErrandTip("This task is already claimed.")
                } else if item.isDone {
                    if let msg = ErrandRegistry.active.collectErrand(uid: item.uid) {
                        self.showErrandTip(msg)
                        self.progressLabel.text = "\(MeritLedger.active.gradeLine())   Coins: \(MeritLedger.active.chips)"
                        self.errandTrigger.setTitle(ErrandRegistry.active.statusLine(), for: .normal)
                    }
                } else {
                    self.showErrandTip("Task not completed yet.")
                }
            }
            sheet.addAction(action)
        }
        sheet.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(sheet, animated: true)
    }

    private func showErrandTip(_ text: String) {
        let alert = UIAlertController(title: "Daily Task", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func soloBoutTapped() {
        let vc = BoutController()
        vc.soloBout = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func pairBoutTapped() {
        let vc = BoutController()
        vc.soloBout = false
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func annalsTapped() {
        navigationController?.pushViewController(AnnalsController(), animated: true)
    }

    @objc private func reelTapped() {
        navigationController?.pushViewController(ReelSpinnerController(), animated: true)
    }

    @objc private func stashTapped() {
        navigationController?.pushViewController(StashController(), animated: true)
    }

    @objc private func configTapped() {
        navigationController?.pushViewController(ConfigPanelController(), animated: true)
    }
}

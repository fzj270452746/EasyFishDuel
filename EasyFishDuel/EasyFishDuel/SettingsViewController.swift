import UIKit

class ConfigPanelController: UIViewController {

    private lazy var backgroundImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "easyImage")
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    private lazy var backBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        b.layer.cornerRadius = 20.scaledW
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        b.layer.shadowColor = UIColor.white.cgColor
        b.layer.shadowOpacity = 0.5
        b.layer.shadowOffset = .zero
        b.layer.shadowRadius = 5
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Settings"
        l.font = UIFont.systemFont(ofSize: 30.scaledF, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.shadowColor = .black
        l.shadowOffset = CGSize(width: 2, height: 2)
        return l
    }()

    private lazy var containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 20.scaledW
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v
    }()

    private lazy var rigorPicker: UISegmentedControl = {
        let items = DifficultyLevel.allCases.map { $0.label }
        let s = UISegmentedControl(items: items)
        s.selectedSegmentIndex = DifficultyPreset.active.botRigor
        s.addTarget(self, action: #selector(rigorAdjusted(_:)), for: .valueChanged)
        s.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        s.selectedSegmentTintColor = .systemYellow
        s.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        s.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        return s
    }()

    private lazy var rulebookTrigger: GlintButton = {
        let b = GlintButton(type: .custom)
        b.setTitle("How to Play", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.scaledF)
        b.addTarget(self, action: #selector(rulebookTapped), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateContainerEntrance()
    }

    private func animateContainerEntrance() {
        containerView.playPreset(.springEntrance, delay: 0.1)
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(containerView)

        let diffLabel = UILabel()
        diffLabel.text = "AI Difficulty"
        diffLabel.textColor = .white
        diffLabel.font = UIFont.systemFont(ofSize: 20.scaledF, weight: .bold)

        let stack = UIStackView(arrangedSubviews: [diffLabel, rigorPicker])
        stack.axis = .vertical
        stack.spacing = 30.scaledW
        containerView.addSubview(stack)
        view.addSubview(rulebookTrigger)

        [backgroundImageView, backBtn, titleLabel, containerView, stack, rulebookTrigger].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.scaledW),
            backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scaledW),
            backBtn.widthAnchor.constraint(equalToConstant: 40.scaledW),
            backBtn.heightAnchor.constraint(equalToConstant: 40.scaledW),

            titleLabel.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40.scaledW),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scaledW),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scaledW),
            containerView.heightAnchor.constraint(equalToConstant: 140.scaledW),

            rulebookTrigger.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20.scaledW),
            rulebookTrigger.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rulebookTrigger.widthAnchor.constraint(equalToConstant: 220.scaledW),
            rulebookTrigger.heightAnchor.constraint(equalToConstant: 52.scaledW),

            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30.scaledW),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.scaledW),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.scaledW)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func rigorAdjusted(_ sender: UISegmentedControl) {
        DifficultyPreset.active.applyPreset(DifficultyLevel(rawValue: sender.selectedSegmentIndex) ?? .easy)
    }

    @objc private func rulebookTapped() {
        navigationController?.pushViewController(RulebookController(), animated: true)
    }
}

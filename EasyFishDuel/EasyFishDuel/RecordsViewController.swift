import UIKit

class AnnalsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var logs: [BoutLog] = []

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
        l.text = "Game Records"
        l.font = UIFont.systemFont(ofSize: 30.scaledF, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.shadowColor = .black
        l.shadowOffset = CGSize(width: 1, height: 1)
        return l
    }()

    private lazy var purgeTrigger: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Clear", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.scaledF)
        b.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        b.layer.cornerRadius = 15.scaledW
        b.addTarget(self, action: #selector(purgeTapped), for: .touchUpInside)
        return b
    }()

    private lazy var tableView: UITableView = {
        let t = UITableView()
        t.backgroundColor = .clear
        t.delegate = self
        t.dataSource = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: "RecordCell")
        t.separatorStyle = .none
        t.showsVerticalScrollIndicator = false
        return t
    }()

    private lazy var blankHint: UILabel = {
        let l = UILabel()
        l.text = "No game records yet.\nGo play a game!"
        l.font = UIFont.systemFont(ofSize: 20.scaledF, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshLogs()
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(purgeTrigger)
        view.addSubview(tableView)
        view.addSubview(blankHint)

        [backgroundImageView, backBtn, titleLabel, purgeTrigger, tableView, blankHint].forEach {
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

            purgeTrigger.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            purgeTrigger.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scaledW),
            purgeTrigger.widthAnchor.constraint(equalToConstant: 70.scaledW),
            purgeTrigger.heightAnchor.constraint(equalToConstant: 35.scaledW),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scaledW),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scaledW),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scaledW),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            blankHint.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blankHint.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func refreshLogs() {
        logs = LogVault.active.fetchLogs()
        tableView.reloadData()
        let empty = logs.isEmpty
        tableView.isHidden = empty
        blankHint.isHidden = !empty
        purgeTrigger.isHidden = empty
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func purgeTapped() {
        let alert = UIAlertController(title: "Clear Records",
                                      message: "Are you sure you want to delete all game records?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            LogVault.active.purgeLogs()
            self?.refreshLogs()
        }))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let container = buildLogContainer()
        cell.contentView.addSubview(container)

        let log = logs[indexPath.row]
        let (modeLabel, resultLabel, dateLabel) = buildLogLabels(for: log)

        container.addSubview(modeLabel)
        container.addSubview(resultLabel)
        container.addSubview(dateLabel)

        [container, modeLabel, resultLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8.scaledW),
            container.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8.scaledW),
            container.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),

            modeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10.scaledW),
            modeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scaledW),

            dateLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10.scaledW),
            dateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15.scaledW),

            resultLabel.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 8.scaledW),
            resultLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scaledW),
            resultLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10.scaledW)
        ])

        return cell
    }

    private func buildLogContainer() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 10.scaledW
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v
    }

    private func buildLogLabels(for log: BoutLog) -> (UILabel, UILabel, UILabel) {
        let modeLabel = UILabel()
        modeLabel.text = log.boutKind
        modeLabel.textColor = .systemYellow
        modeLabel.font = UIFont.boldSystemFont(ofSize: 16.scaledF)

        let resultLabel = UILabel()
        resultLabel.text = log.tally
        resultLabel.textColor = .white
        resultLabel.font = UIFont.systemFont(ofSize: 18.scaledF, weight: .bold)

        let dateLabel = UILabel()
        dateLabel.text = log.formattedDate
        dateLabel.textColor = .lightGray
        dateLabel.font = UIFont.systemFont(ofSize: 12.scaledF)

        return (modeLabel, resultLabel, dateLabel)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let del = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self = self else { return }
            LogVault.active.expungeLog(at: indexPath.row)
            self.logs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if self.logs.isEmpty {
                self.tableView.isHidden = true
                self.blankHint.isHidden = false
                self.purgeTrigger.isHidden = true
            }
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [del])
    }
}

import UIKit

class StashController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var contents: [HaulEntry] = []

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
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "My Backpack"
        l.font = UIFont.systemFont(ofSize: 30.scaledF, weight: .bold)
        l.textColor = .white
        return l
    }()

    private lazy var chipBadge: UILabel = {
        let l = UILabel()
        l.textColor = .systemYellow
        l.font = UIFont.boldSystemFont(ofSize: 18.scaledF)
        l.textAlignment = .right
        return l
    }()

    private lazy var tableView: UITableView = {
        let t = UITableView()
        t.backgroundColor = .clear
        t.register(UITableViewCell.self, forCellReuseIdentifier: "FishCell")
        t.dataSource = self
        t.delegate = self
        t.separatorStyle = .none
        t.rowHeight = 84.scaledW
        t.estimatedRowHeight = 84.scaledW
        return t
    }()

    private lazy var blankHint: UILabel = {
        let l = UILabel()
        l.text = "No fish yet.\nGo catch some fish!"
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 20.scaledF, weight: .medium)
        return l
    }()

    private func wareLabel(for symbol: String) -> String {
        switch symbol {
        case "fish.fill": return "Minnow"
        case "leaf.fill": return "Leaf Fish"
        case "drop.fill": return "Wave Fish"
        case "tortoise.fill": return "Shell Fish"
        case "bolt.fill": return "Thunder Fish"
        case "star.fill": return "Star Fish"
        default: return "Unknown Fish"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStash()
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(chipBadge)
        view.addSubview(tableView)
        view.addSubview(blankHint)

        [backgroundImageView, backBtn, titleLabel, chipBadge, tableView, blankHint].forEach {
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

            chipBadge.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scaledW),
            chipBadge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scaledW),
            chipBadge.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scaledW),

            tableView.topAnchor.constraint(equalTo: chipBadge.bottomAnchor, constant: 12.scaledW),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scaledW),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scaledW),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.scaledW),

            blankHint.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blankHint.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func refreshStash() {
        contents = MeritLedger.active.loadStash()
        chipBadge.text = "Coins: \(MeritLedger.active.chips)"
        tableView.reloadData()
        let empty = contents.isEmpty
        tableView.isHidden = empty
        blankHint.isHidden = !empty
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FishCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let entry = contents[indexPath.row]
        let wrap = UIView()
        wrap.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        wrap.layer.cornerRadius = 10.scaledW
        cell.contentView.addSubview(wrap)
        wrap.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView()
        icon.image = UIImage(systemName: entry.wareKind)
        icon.tintColor = .systemYellow
        icon.contentMode = .scaleAspectFit

        let countBadge = UILabel()
        countBadge.text = "x\(entry.amount)"
        countBadge.textColor = .systemYellow
        countBadge.font = UIFont.boldSystemFont(ofSize: 18.scaledF)

        let nameBadge = UILabel()
        nameBadge.text = wareLabel(for: entry.wareKind)
        nameBadge.textColor = .white
        nameBadge.font = UIFont.boldSystemFont(ofSize: 17.scaledF)
        nameBadge.adjustsFontSizeToFitWidth = true
        nameBadge.minimumScaleFactor = 0.75

        let barterBtn = UIButton(type: .system)
        barterBtn.setTitle("Exchange", for: .normal)
        barterBtn.tintColor = .white
        barterBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.75)
        barterBtn.layer.cornerRadius = 8.scaledW
        barterBtn.tag = indexPath.row
        barterBtn.addTarget(self, action: #selector(barterTapped(_:)), for: .touchUpInside)

        wrap.addSubview(icon)
        wrap.addSubview(nameBadge)
        wrap.addSubview(countBadge)
        wrap.addSubview(barterBtn)
        [icon, nameBadge, countBadge, barterBtn].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            wrap.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6.scaledW),
            wrap.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6.scaledW),
            wrap.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            wrap.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),

            icon.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 12.scaledW),
            icon.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 30.scaledW),
            icon.heightAnchor.constraint(equalToConstant: 30.scaledW),

            nameBadge.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10.scaledW),
            nameBadge.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),

            countBadge.leadingAnchor.constraint(equalTo: nameBadge.trailingAnchor, constant: 8.scaledW),
            countBadge.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            countBadge.trailingAnchor.constraint(lessThanOrEqualTo: barterBtn.leadingAnchor, constant: -8.scaledW),

            barterBtn.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -12.scaledW),
            barterBtn.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            barterBtn.widthAnchor.constraint(equalToConstant: 112.scaledW),
            barterBtn.heightAnchor.constraint(equalToConstant: 34.scaledW)
        ])

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        84.scaledW
    }

    @objc private func barterTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx >= 0, idx < contents.count else { return }
        let entry = contents[idx]
        let gain = MeritLedger.active.barterWare(kind: entry.wareKind, amount: 1)
        if gain > 0 {
            ErrandRegistry.active.markProgress(kind: .haulBarter, by: 1)
        }
        let message = gain > 0 ? "1 fish exchanged for \(gain) coins." : "Exchange failed."
        let alert = UIAlertController(title: "Exchange", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.refreshStash()
        }))
        present(alert, animated: true)
    }
}

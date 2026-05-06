import UIKit

class BackpackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var items: [FishInventoryItem] = []

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
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Backpack"
        label.font = UIFont.systemFont(ofSize: 30.sp, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var coinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemYellow
        label.font = UIFont.boldSystemFont(ofSize: 18.sp)
        label.textAlignment = .right
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(UITableViewCell.self, forCellReuseIdentifier: "FishCell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.rowHeight = 84.w
        table.estimatedRowHeight = 84.w
        return table
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No fish yet.\nGo catch some fish!"
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20.sp, weight: .medium)
        return label
    }()

    private func fishDisplayName(for symbol: String) -> String {
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
        loadData()
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(coinLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        [backgroundImageView, backBtn, titleLabel, coinLabel, tableView, emptyLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

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

            coinLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.w),
            coinLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.w),
            coinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.w),

            tableView.topAnchor.constraint(equalTo: coinLabel.bottomAnchor, constant: 12.w),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.w),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.w),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.w),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadData() {
        items = PlayerProgressManager.shared.loadInventory()
        coinLabel.text = "Coins: \(PlayerProgressManager.shared.coins)"
        tableView.reloadData()
        let isEmpty = items.isEmpty
        tableView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FishCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let item = items[indexPath.row]
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        container.layer.cornerRadius = 10.w
        cell.contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        let fishIcon = UIImageView()
        fishIcon.image = UIImage(systemName: item.fishType)
        fishIcon.tintColor = .systemYellow
        fishIcon.contentMode = .scaleAspectFit

        let countLabel = UILabel()
        countLabel.text = "x\(item.count)"
        countLabel.textColor = .systemYellow
        countLabel.font = UIFont.boldSystemFont(ofSize: 18.sp)

        let nameLabel = UILabel()
        nameLabel.text = fishDisplayName(for: item.fishType)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17.sp)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.75

        let exchangeBtn = UIButton(type: .system)
        exchangeBtn.setTitle("Exchange", for: .normal)
        exchangeBtn.tintColor = .white
        exchangeBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.75)
        exchangeBtn.layer.cornerRadius = 8.w
        exchangeBtn.tag = indexPath.row
        exchangeBtn.addTarget(self, action: #selector(exchangeTapped(_:)), for: .touchUpInside)

        container.addSubview(fishIcon)
        container.addSubview(nameLabel)
        container.addSubview(countLabel)
        container.addSubview(exchangeBtn)
        [fishIcon, nameLabel, countLabel, exchangeBtn].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6.w),
            container.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6.w),
            container.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),

            fishIcon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.w),
            fishIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            fishIcon.widthAnchor.constraint(equalToConstant: 30.w),
            fishIcon.heightAnchor.constraint(equalToConstant: 30.w),

            nameLabel.leadingAnchor.constraint(equalTo: fishIcon.trailingAnchor, constant: 10.w),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            countLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8.w),
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: exchangeBtn.leadingAnchor, constant: -8.w),

            exchangeBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.w),
            exchangeBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            exchangeBtn.widthAnchor.constraint(equalToConstant: 112.w),
            exchangeBtn.heightAnchor.constraint(equalToConstant: 34.w)
        ])

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        84.w
    }

    @objc private func exchangeTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0, index < items.count else { return }
        let item = items[index]
        let gain = PlayerProgressManager.shared.exchangeFishToCoins(type: item.fishType, count: 1)
        if gain > 0 {
            DailyTaskManager.shared.updateProgress(for: .sellFish, amount: 1)
        }
        let message = gain > 0 ? "1 fish exchanged for \(gain) coins." : "Exchange failed."
        let alert = UIAlertController(title: "Exchange", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.loadData()
        }))
        present(alert, animated: true)
    }
}

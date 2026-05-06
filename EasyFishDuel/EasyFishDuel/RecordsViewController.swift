import UIKit

/// 游戏记录模型
struct GameRecord: Codable {
    /// 游戏日期
    let date: Date
    /// 游戏模式
    let mode: String // "Single Player" or "Two Players"
    /// 游戏结果
    let result: String // e.g., "Player 1 Wins (28 - 24)"
}

/// 游戏记录管理器
class RecordManager {
    static let shared = RecordManager()
    private let userDefaultsKey = "GameRecords"
    
    /// 获取所有记录
    /// - Returns: 记录数组
    func getRecords() -> [GameRecord] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let records = try? JSONDecoder().decode([GameRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    /// 保存记录
    /// - Parameter record: 游戏记录
    func addRecord(_ record: GameRecord) {
        var records = getRecords()
        records.insert(record, at: 0) // 最新记录在前面
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    /// 删除单条记录
    /// - Parameter index: 记录索引
    func deleteRecord(at index: Int) {
        var records = getRecords()
        guard index >= 0 && index < records.count else { return }
        records.remove(at: index)
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    /// 清除所有记录
    func clearRecords() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

/// 游戏记录控制器
class RecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /// 游戏记录数据源
    private var records: [GameRecord] = []
    
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
        label.text = "Game Records"
        label.font = UIFont.systemFont(ofSize: 30.sp, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    /// 清除按钮
    private lazy var clearBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.sp)
        button.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        button.layer.cornerRadius = 15.w
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()
    
    /// 列表视图
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "RecordCell")
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    /// 空数据提示文本
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No game records yet.\nGo play a game!"
        label.font = UIFont.systemFont(ofSize: 20.sp, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    /// 视图加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    /// 设置UI
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(clearBtn)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            clearBtn.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            clearBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.w),
            clearBtn.widthAnchor.constraint(equalToConstant: 70.w),
            clearBtn.heightAnchor.constraint(equalToConstant: 35.w),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.w),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.w),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.w),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    /// 加载数据
    private func loadData() {
        records = RecordManager.shared.getRecords()
        tableView.reloadData()
        
        let isEmpty = records.isEmpty
        tableView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
        clearBtn.isHidden = isEmpty
    }
    
    /// 返回按钮点击事件
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 清除按钮点击事件
    @objc private func clearTapped() {
        let alert = UIAlertController(title: "Clear Records", message: "Are you sure you want to delete all game records?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            RecordManager.shared.clearRecords()
            self?.loadData()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource & Delegate
    
    /// 返回行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    /// 返回单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // 移除旧的子视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        container.layer.cornerRadius = 10.w
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        cell.contentView.addSubview(container)
        
        let record = records[indexPath.row]
        
        let modeLabel = UILabel()
        modeLabel.text = record.mode
        modeLabel.textColor = .systemYellow
        modeLabel.font = UIFont.boldSystemFont(ofSize: 16.sp)
        
        let resultLabel = UILabel()
        resultLabel.text = record.result
        resultLabel.textColor = .white
        resultLabel.font = UIFont.systemFont(ofSize: 18.sp, weight: .bold)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateLabel = UILabel()
        dateLabel.text = formatter.string(from: record.date)
        dateLabel.textColor = .lightGray
        dateLabel.font = UIFont.systemFont(ofSize: 12.sp)
        
        container.addSubview(modeLabel)
        container.addSubview(resultLabel)
        container.addSubview(dateLabel)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8.w),
            container.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8.w),
            container.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            
            modeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10.w),
            modeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.w),
            
            dateLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10.w),
            dateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15.w),
            
            resultLabel.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 8.w),
            resultLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.w),
            resultLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10.w)
        ])
        
        return cell
    }
    
    /// 滑动删除功能
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            RecordManager.shared.deleteRecord(at: indexPath.row)
            self.records.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if self.records.isEmpty {
                self.tableView.isHidden = true
                self.emptyLabel.isHidden = false
                self.clearBtn.isHidden = true
            }
            
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

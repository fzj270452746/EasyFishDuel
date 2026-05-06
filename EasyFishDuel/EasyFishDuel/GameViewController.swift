import UIKit

/// 游戏主控制器
class GameViewController: UIViewController {

    /// 是否为单人模式（人机对战）
    var isSinglePlayer: Bool = false
    
    // MARK: - Game Data
    
    /// 玩家1手牌
    private var player1Hand: [EasyModel] = []
    /// 玩家2手牌
    private var player2Hand: [EasyModel] = []
    /// 公共牌区
    private var publicCards: [EasyModel] = []
    /// 玩家1得分牌
    private var player1ScorePile: [EasyModel] = []
    /// 玩家2得分牌
    private var player2ScorePile: [EasyModel] = []
    
    /// 当前回合 (1: 玩家1, 2: 玩家2/AI)
    private var currentPlayer: Int = 1
    /// 游戏是否结束
    private var isGameOver: Bool = false
    
    // MARK: - UI Components
    
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
    
    /// 顶部玩家 (玩家2 或 AI) 信息
    private lazy var topPlayerLabel: UILabel = createPlayerLabel(text: isSinglePlayer ? "AI" : "Player 2")
    private lazy var topHandCountLabel: UILabel = createCountLabel()
    private lazy var topScoreLabel: UILabel = createCountLabel()
    private lazy var topPlayBtn: EasyButton = createPlayButton(title: "P2 Play", action: #selector(topPlayTapped))
    
    /// 底部玩家 (玩家1) 信息
    private lazy var bottomPlayerLabel: UILabel = createPlayerLabel(text: "Player 1")
    private lazy var bottomHandCountLabel: UILabel = createCountLabel()
    private lazy var bottomScoreLabel: UILabel = createCountLabel()
    private lazy var bottomPlayBtn: EasyButton = createPlayButton(title: "P1 Play", action: #selector(bottomPlayTapped))
    
    /// 公共牌区容器
    private lazy var publicAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 15.w
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return view
    }()
    
    /// 公共牌展示的 ScrollView
    private lazy var publicScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    /// 提示信息标签
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Game Start! Player 1's turn."
        label.font = UIFont.boldSystemFont(ofSize: 18.sp)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 15.w
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        label.clipsToBounds = true
        return label
    }()

    private lazy var levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16.sp)
        label.textColor = .systemYellow
        label.textAlignment = .left
        return label
    }()

    private lazy var expProgressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.35)
        progress.progressTintColor = .systemGreen
        progress.layer.cornerRadius = 4.w
        progress.clipsToBounds = true
        return progress
    }()

    private lazy var dropFishIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemYellow
        view.isHidden = true
        return view
    }()


    private lazy var expContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.layer.cornerRadius = 10.w
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        return view
    }()

    /// 视图加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startGame()
    }
    
    // MARK: - Setup UI
    
    /// 设置UI
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        
        view.addSubview(topPlayerLabel)
        view.addSubview(topHandCountLabel)
        view.addSubview(topScoreLabel)
        view.addSubview(topPlayBtn)
        
        view.addSubview(bottomPlayerLabel)
        view.addSubview(bottomHandCountLabel)
        view.addSubview(bottomScoreLabel)
        view.addSubview(bottomPlayBtn)
        
        view.addSubview(publicAreaView)
        publicAreaView.addSubview(publicScrollView)
        view.addSubview(infoLabel)
        view.addSubview(expContainerView)
        expContainerView.addSubview(levelLabel)
        expContainerView.addSubview(expProgressView)
        view.addSubview(dropFishIconView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        topPlayerLabel.translatesAutoresizingMaskIntoConstraints = false
        topHandCountLabel.translatesAutoresizingMaskIntoConstraints = false
        topScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        topPlayBtn.translatesAutoresizingMaskIntoConstraints = false
        bottomPlayerLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomHandCountLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomPlayBtn.translatesAutoresizingMaskIntoConstraints = false
        publicAreaView.translatesAutoresizingMaskIntoConstraints = false
        publicScrollView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        expContainerView.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        expProgressView.translatesAutoresizingMaskIntoConstraints = false
        dropFishIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.w),
            backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.w),
            backBtn.widthAnchor.constraint(equalToConstant: 40.w),
            backBtn.heightAnchor.constraint(equalToConstant: 40.w),
            
            // Top Player (P2)
            topPlayerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.w),
            topPlayerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            topHandCountLabel.topAnchor.constraint(equalTo: topPlayerLabel.bottomAnchor, constant: 5.w),
            topHandCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60.w),
            
            topScoreLabel.topAnchor.constraint(equalTo: topPlayerLabel.bottomAnchor, constant: 5.w),
            topScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60.w),
            
            topPlayBtn.topAnchor.constraint(equalTo: topHandCountLabel.bottomAnchor, constant: 5.w),
            topPlayBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topPlayBtn.widthAnchor.constraint(equalToConstant: 140.w),
            topPlayBtn.heightAnchor.constraint(equalToConstant: 50.w),
            
            // Bottom Player (P1)
            bottomPlayBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.w),
            bottomPlayBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomPlayBtn.widthAnchor.constraint(equalToConstant: 140.w),
            bottomPlayBtn.heightAnchor.constraint(equalToConstant: 50.w),
            
            bottomHandCountLabel.bottomAnchor.constraint(equalTo: bottomPlayBtn.topAnchor, constant: -5.w),
            bottomHandCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60.w),
            
            bottomScoreLabel.bottomAnchor.constraint(equalTo: bottomPlayBtn.topAnchor, constant: -5.w),
            bottomScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60.w),
            
            bottomPlayerLabel.bottomAnchor.constraint(equalTo: bottomHandCountLabel.topAnchor, constant: -5.w),
            bottomPlayerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Public Area
            publicAreaView.topAnchor.constraint(equalTo: topPlayBtn.bottomAnchor, constant: 5.w),
            publicAreaView.bottomAnchor.constraint(equalTo: bottomPlayerLabel.topAnchor, constant: -5.w),
            publicAreaView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            publicAreaView.widthAnchor.constraint(equalToConstant: 160.w),
            
            publicScrollView.topAnchor.constraint(equalTo: publicAreaView.topAnchor, constant: 10.w),
            publicScrollView.bottomAnchor.constraint(equalTo: publicAreaView.bottomAnchor, constant: -10.w),
            publicScrollView.leadingAnchor.constraint(equalTo: publicAreaView.leadingAnchor),
            publicScrollView.trailingAnchor.constraint(equalTo: publicAreaView.trailingAnchor),
            
            expContainerView.topAnchor.constraint(equalTo: topScoreLabel.bottomAnchor, constant: 5.w),
            expContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            expContainerView.widthAnchor.constraint(equalToConstant: 220.w),

            levelLabel.topAnchor.constraint(equalTo: expContainerView.topAnchor, constant: 10.w),
            levelLabel.leadingAnchor.constraint(equalTo: expContainerView.leadingAnchor, constant: 10.w),
            levelLabel.trailingAnchor.constraint(equalTo: expContainerView.trailingAnchor, constant: -10.w),

            expProgressView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8.w),
            expProgressView.centerXAnchor.constraint(equalTo: expContainerView.centerXAnchor),
            expProgressView.widthAnchor.constraint(equalTo: expContainerView.widthAnchor, constant: -20.w),
            expProgressView.heightAnchor.constraint(equalToConstant: 10.w),
            expProgressView.bottomAnchor.constraint(equalTo: expContainerView.bottomAnchor, constant: -10.w),

            // Info Label
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: publicAreaView.trailingAnchor, constant: 10.w),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.w),
            infoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.w),

            dropFishIconView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 10.w),
            dropFishIconView.centerXAnchor.constraint(equalTo: infoLabel.centerXAnchor),
            dropFishIconView.widthAnchor.constraint(equalToConstant: 28.w),
            dropFishIconView.heightAnchor.constraint(equalToConstant: 28.w)
        ])
        
        infoLabel.numberOfLines = 0
        levelLabel.textAlignment = .center
        
        if isSinglePlayer {
            topPlayBtn.isHidden = true // AI自动出牌，隐藏按钮
        } else {
            expContainerView.isHidden = true
        }
    }
    
    // MARK: - Helpers
    
    /// 创建玩家名称标签
    /// - Parameter text: 标签文本
    private func createPlayerLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 22.sp)
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }
    
    /// 创建数量标签
    /// - Returns: 标签实例
    private func createCountLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.sp, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        return label
    }
    
    /// 创建出牌按钮
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - action: 点击事件
    /// - Returns: 按钮实例
    private func createPlayButton(title: String, action: Selector) -> EasyButton {
        let button = EasyButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.sp)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Game Logic
    
    /// 开始游戏
    private func startGame() {
        let fullDeck = [
            modelhei1, modelhei2, modelhei3, modelhei4, modelhei5, modelhei6, modelhei7, modelhei8, modelhei9, modelhei10, modelhei11, modelhei12, modelhei13,
            modelhong1, modelhong2, modelhong3, modelhong4, modelhong5, modelhong6, modelhong7, modelhong8, modelhong9, modelhong10, modelhong11, modelhong12, modelhong13,
            modelmei1, modelmei2, modelmei3, modelmei4, modelmei5, modelmei6, modelmei7
        ].shuffled()
        
        let halfCount = fullDeck.count / 2
        // 均分纸牌
        player1Hand = Array(fullDeck[0..<halfCount])
        player2Hand = Array(fullDeck[halfCount..<fullDeck.count])
        
        publicCards.removeAll()
        player1ScorePile.removeAll()
        player2ScorePile.removeAll()
        
        currentPlayer = 1
        isGameOver = false
        
        updateUI()
        renderPublicCards()
        showInfo("Game Start!\nPlayer 1's turn.")
    }
    
    /// 更新UI
    private func updateUI() {
        topHandCountLabel.text = "Hand: \(player2Hand.count)"
        topScoreLabel.text = "Score: \(player2ScorePile.count)"
        
        bottomHandCountLabel.text = "Hand: \(player1Hand.count)"
        bottomScoreLabel.text = "Score: \(player1ScorePile.count)"
        levelLabel.text = "\(PlayerProgressManager.shared.progressText())"
        expProgressView.progress = PlayerProgressManager.shared.progressRate()
        
        // 更新按钮状态
        if !isGameOver {
            if isSinglePlayer {
                bottomPlayBtn.isEnabled = (currentPlayer == 1)
            } else {
                bottomPlayBtn.isEnabled = (currentPlayer == 1)
                topPlayBtn.isEnabled = (currentPlayer == 2)
            }
        } else {
            bottomPlayBtn.isEnabled = false
            topPlayBtn.isEnabled = false
        }
    }
    
    /// 渲染公共牌区
    private func renderPublicCards(animateNewCardForPlayer player: Int? = nil) {
        publicScrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let cardWidth: CGFloat = 90.w
        let cardHeight: CGFloat = 135.w
        let overlap: CGFloat = 35.w // 牌叠放的间距
        
        var currentY: CGFloat = 10.w
        
        for (index, card) in publicCards.enumerated() {
            let containerView = UIView(frame: CGRect(x: (160.w - cardWidth) / 2, y: currentY, width: cardWidth, height: cardHeight))
            
            // 添加阴影
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.6
            containerView.layer.shadowOffset = CGSize(width: 2, height: 4)
            containerView.layer.shadowRadius = 5
            
            let imgView = UIImageView(image: card.image)
            imgView.contentMode = .scaleAspectFill
            imgView.frame = containerView.bounds
            imgView.layer.cornerRadius = 6
            imgView.clipsToBounds = true
            
            containerView.addSubview(imgView)
            publicScrollView.addSubview(containerView)
            
            // 为最新出的一张牌添加飞入动画
            if index == publicCards.count - 1, let player = player {
                let dy: CGFloat = (player == 1) ? self.view.bounds.height : -self.view.bounds.height
                containerView.transform = CGAffineTransform(translationX: 0, y: dy)
                containerView.alpha = 0
                
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    containerView.transform = .identity
                    containerView.alpha = 1
                }, completion: nil)
            }
            
            currentY += overlap
        }
        
        let contentHeight = currentY + cardHeight - overlap + 20.w
        publicScrollView.contentSize = CGSize(width: 160.w, height: max(contentHeight, publicAreaView.bounds.height))
        
        // 自动滚动到底部
        if contentHeight > publicAreaView.bounds.height {
            let bottomOffset = CGPoint(x: 0, y: contentHeight - publicAreaView.bounds.height)
            publicScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    /// 显示提示信息
    /// - Parameter text: 提示文本
    private func showInfo(_ text: String) {
        infoLabel.text = text
        // 简单的弹跳动画
        infoLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        infoLabel.alpha = 0.5
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.infoLabel.transform = .identity
            self.infoLabel.alpha = 1.0
        }, completion: nil)
    }
    
    /// 返回按钮点击事件
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 底部玩家(P1)出牌点击事件
    @objc private func bottomPlayTapped() {
        playCard(for: 1)
    }
    
    /// 顶部玩家(P2)出牌点击事件
    @objc private func topPlayTapped() {
        playCard(for: 2)
    }
    
    /// 执行出牌逻辑
    /// - Parameter player: 玩家编号 (1 或 2)
    private func playCard(for player: Int) {
        guard !isGameOver else { return }
        
        var playedCard: EasyModel
        if player == 1 {
            playedCard = player1Hand.removeFirst()
        } else {
            playedCard = player2Hand.removeFirst()
        }
        
        publicCards.append(playedCard)
        updateUI()
        renderPublicCards(animateNewCardForPlayer: player)
        
        checkFish(for: player, playedCard: playedCard)
    }
    
    /// 检查是否勾到鱼
    /// - Parameters:
    ///   - player: 玩家编号
    ///   - playedCard: 刚打出的牌
    private func checkFish(for player: Int, playedCard: EasyModel) {
        // 检查是否有相同数字的牌 (排除刚打出的这张)
        if let matchIndex = publicCards.dropLast().firstIndex(where: { $0.value == playedCard.value }) {
            // 勾到鱼了！
            let wonCards = Array(publicCards[matchIndex...])
            publicCards.removeSubrange(matchIndex...)
            
            if player == 1 {
                player1ScorePile.append(contentsOf: wonCards)
                rewardFish(for: wonCards.count, playerName: "Player 1")
            } else {
                player2ScorePile.append(contentsOf: wonCards)
                let name = isSinglePlayer ? "AI" : "Player 2"
                showInfo("\(name) caught \(wonCards.count) fish!")
            }
            
            // 延迟一点更新UI，让玩家看清
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateUI()
                self.renderPublicCards()
                self.checkGameOver()
                if !self.isGameOver {
                    self.switchTurn()
                }
            }
        } else {
            // 没勾到
            checkGameOver()
            if !isGameOver {
                switchTurn()
            }
        }
    }

    private func rewardFish(for baseCount: Int, playerName: String) {
        let fishType = PlayerProgressManager.shared.fishTypeByProbability(for: PlayerProgressManager.shared.level)
        let reward = PlayerProgressManager.shared.addFishCatch(baseFishCount: baseCount, fishType: fishType)
        DailyTaskManager.shared.updateProgress(for: .catchFish, amount: reward.rewarded)
        var text = "\(playerName) caught \(baseCount)!\n+\(reward.rewarded) reward fish"
        if reward.levelUpCount > 0 {
            text += "\nLevel Up! Lv\(PlayerProgressManager.shared.level)"
        }
        showInfo(text)
        showDropFish(symbol: fishType)
        updateUI()
    }

    private func showDropFish(symbol: String) {
        dropFishIconView.image = UIImage(systemName: symbol)
        dropFishIconView.isHidden = false
    }
    
    /// 切换回合
    private func switchTurn() {
        currentPlayer = (currentPlayer == 1) ? 2 : 1
        updateUI()
        
        let name = currentPlayer == 1 ? "Player 1" : (isSinglePlayer ? "AI" : "Player 2")
        showInfo("\(name)'s turn.")
        
        if isSinglePlayer && currentPlayer == 2 {
            // AI 自动出牌，结合难度设置
            let difficulty = SettingsManager.shared.aiDifficulty
            // 简单0.8-1.5, 中等0.5-1.0, 困难0.3-0.6
            var minDelay = 0.8
            var maxDelay = 1.5
            if difficulty == 1 {
                minDelay = 0.5
                maxDelay = 1.0
            } else if difficulty == 2 {
                minDelay = 0.3
                maxDelay = 0.6
            }
            
            let delay = Double.random(in: minDelay...maxDelay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if !self.isGameOver && self.currentPlayer == 2 {
                    self.playCard(for: 2)
                }
            }
        }
    }
    
    /// 检查游戏是否结束
    private func checkGameOver() {
        if player1Hand.isEmpty || player2Hand.isEmpty {
            isGameOver = true
            
            let p1Total = player1Hand.count + player1ScorePile.count
            let p2Total = player2Hand.count + player2ScorePile.count
            
            var resultText = ""
            if p1Total > p2Total {
                resultText = "Player 1 Wins! (\(p1Total) - \(p2Total))"
            } else if p2Total > p1Total {
                let p2Name = isSinglePlayer ? "AI" : "Player 2"
                resultText = "\(p2Name) Wins! (\(p2Total) - \(p1Total))"
            } else {
                resultText = "Draw! (\(p1Total) - \(p2Total))"
            }
            
            showInfo("Game Over!\n\(resultText)")
            
            // 保存记录
            let mode = isSinglePlayer ? "Single Player" : "Two Players"
            let record = GameRecord(date: Date(), mode: mode, result: resultText)
            RecordManager.shared.addRecord(record)
            DailyTaskManager.shared.updateProgress(for: .playMatch, amount: 1)
            
            // 显示结束弹窗
            let alert = UIAlertController(title: "Game Over", message: resultText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                self.startGame()
            }))
            alert.addAction(UIAlertAction(title: "Exit", style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

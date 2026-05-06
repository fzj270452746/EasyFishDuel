import UIKit

/// 玩法说明控制器
class InstructionsViewController: UIViewController {

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
        label.text = "How to Play"
        label.font = UIFont.systemFont(ofSize: 30.sp, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    /// 文本容器
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 20.w
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return view
    }()
    
    /// 说明文本
    private lazy var instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 18.sp, weight: .medium)
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        
        let text = """
        Welcome to Easy Fish Duel!

        [ Two-Player Mode ]
        Two players play on the same device.
        
        Preparation:
        A deck of 52 cards (without Jokers) is shuffled and divided equally between two players. Each player holds 26 cards.
        
        How to Play:
        Players take turns playing 1 card to the "Public Area" in the center of the screen. The newly played card is stacked below the previous one, forming a line.
        
        Fishing Rule:
        When you play a card, if its number matches ANY card already in the Public Area (regardless of suit), you "catch the fish"! You win all the cards between your played card and the matching card, including both matching cards. These won cards are added to your score pile.
        
        End Game:
        The game ends when a player runs out of cards in their hand. The player with the most cards in their score pile wins the game!

        [ Level & Fish Drop System ]
        Your account has Level and EXP progression.

        EXP Gain:
        You gain EXP from fish rewards when Player 1 catches fish.

        Reward Multiplier:
        Fish reward amount scales with level (higher level, higher multiplier).

        Fish Drop Probability:
        Fish are dropped by a probability pool.
        As your level increases, the chance of getting higher-value fish increases.
        Low-level fish can still appear, but high-level fish become more frequent.

        Backpack & Coins:
        Caught fish are stored in My Backpack.
        You can sell fish for coins, then use coins in Slot Machine.

        [ Slot Machine: Fish Tide Slot ]
        Start with 100 coins. Each spin costs 5 coins.

        Reels:
        There are 3 reels with ocean symbols.

        Rewards:
        - Pair match: gain base reward + combo bonus.
        - Triple match: gain higher reward + bigger combo bonus.

        Creative Mechanic - Tide Rush:
        Each successful spin increases Tide energy. At 3/3 Tide, you trigger "Tide Rush" and receive a bonus burst reward.

        Strategy:
        Misses reset combo and reduce Tide, so decide when to continue spinning or Cash Out.
        
        [ Single-Player Mode ]
        Play against the AI. The rules are exactly the same as the Two-Player mode.
        
        Good luck and have fun!
        """
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18.sp, weight: .medium),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        textView.attributedText = NSAttributedString(string: text, attributes: attributes)
        
        return textView
    }()

    /// 视图加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    /// 视图将要出现，添加入场动画
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        containerView.transform = CGAffineTransform(translationX: 0, y: 100)
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
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
        containerView.addSubview(instructionsTextView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        instructionsTextView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30.w),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.w),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.w),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.w),
            
            instructionsTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20.w),
            instructionsTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.w),
            instructionsTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.w),
            instructionsTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.w)
        ])
    }
    
    /// 返回按钮点击事件
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

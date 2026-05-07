import UIKit

class RulebookController: UIViewController {

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
        l.text = "How to Play"
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

    private lazy var ruleContent: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 18.scaledF, weight: .medium)
        tv.isEditable = false
        tv.showsVerticalScrollIndicator = false

        let text = """
        Welcome to FishSlotDuel!

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

        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = 8

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18.scaledF, weight: .medium),
            .foregroundColor: UIColor.white,
            .paragraphStyle: ps
        ]

        tv.attributedText = NSAttributedString(string: text, attributes: attrs)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.playPreset(.slideUp, delay: 0.1)
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        containerView.addSubview(ruleContent)

        [backgroundImageView, backBtn, titleLabel, containerView, ruleContent].forEach {
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

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30.scaledW),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scaledW),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scaledW),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.scaledW),

            ruleContent.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20.scaledW),
            ruleContent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.scaledW),
            ruleContent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.scaledW),
            ruleContent.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.scaledW)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

import UIKit

class ReelSpinnerController: UIViewController {

    private let iconSet = ["fish.fill", "tortoise.fill", "drop.fill", "star.fill", "bolt.fill", "leaf.fill"]
    private let wagerCost = 5

    private var chips: Int = 0
    private var streak: Int = 0
    private var surgeGauge: Int = 0
    private var isRolling = false

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
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Fish Tide Slot"
        l.font = UIFont.systemFont(ofSize: 34.scaledF, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        l.shadowColor = .black
        l.shadowOffset = CGSize(width: 2, height: 2)
        return l
    }()

    private lazy var chipBadge: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = UIFont.boldSystemFont(ofSize: 18.scaledF)
        l.textColor = .systemYellow
        l.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        l.layer.cornerRadius = 12.scaledW
        l.layer.borderWidth = 1
        l.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        l.layer.masksToBounds = true
        return l
    }()

    private lazy var hintLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = UIFont.boldSystemFont(ofSize: 18.scaledF)
        l.textColor = .systemYellow
        l.numberOfLines = 0
        l.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        l.layer.cornerRadius = 14.scaledW
        l.layer.masksToBounds = true
        return l
    }()

    private lazy var drumIcon1 = makeDrumIcon()
    private lazy var drumIcon2 = makeDrumIcon()
    private lazy var drumIcon3 = makeDrumIcon()

    private lazy var drumFace1 = makeDrumCard(with: drumIcon1)
    private lazy var drumFace2 = makeDrumCard(with: drumIcon2)
    private lazy var drumFace3 = makeDrumCard(with: drumIcon3)

    private lazy var drumTray: UIStackView = {
        let s = UIStackView(arrangedSubviews: [drumFace1, drumFace2, drumFace3])
        s.axis = .horizontal
        s.spacing = 16.scaledW
        s.distribution = .fillEqually
        return s
    }()

    private var shownIcon1 = "fish.fill"
    private var shownIcon2 = "fish.fill"
    private var shownIcon3 = "fish.fill"

    private lazy var rollTrigger: GlintButton = {
        let b = GlintButton(type: .custom)
        b.setTitle("Spin (-\(wagerCost))", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24.scaledF)
        b.addTarget(self, action: #selector(rollTapped), for: .touchUpInside)
        return b
    }()

    private lazy var barterTrigger: GlintButton = {
        let b = GlintButton(type: .custom)
        b.setTitle("Sell Fish", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.scaledF)
        b.addTarget(self, action: #selector(barterTapped), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        chips = MeritLedger.active.chips
        setupUI()
        refreshHint(message: "Welcome! Catch combo and trigger Tide Rush.")
        shuffleDrums()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let latest = MeritLedger.active.chips
        let wasDry = chips < wagerCost
        chips = latest
        rollTrigger.isEnabled = chips >= wagerCost
        refreshHint(message: chips >= wagerCost ? "Ready to spin!" : "Not enough coins. Sell fish to continue.")
        if wasDry && chips >= wagerCost {
            pulseRollTrigger()
        }
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)
        view.addSubview(chipBadge)
        view.addSubview(hintLabel)
        view.addSubview(drumTray)
        view.addSubview(rollTrigger)
        view.addSubview(barterTrigger)

        [backgroundImageView, backBtn, titleLabel, chipBadge, hintLabel, drumTray, rollTrigger, barterTrigger].forEach {
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

            chipBadge.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scaledW),
            chipBadge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scaledW),
            chipBadge.widthAnchor.constraint(equalToConstant: 150.scaledW),
            chipBadge.heightAnchor.constraint(equalToConstant: 36.scaledW),

            hintLabel.topAnchor.constraint(equalTo: chipBadge.bottomAnchor, constant: 12.scaledW),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.scaledW),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.scaledW),
            hintLabel.heightAnchor.constraint(equalToConstant: 88.scaledW),

            drumTray.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            drumTray.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.scaledW),
            drumTray.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.scaledW),
            drumTray.heightAnchor.constraint(equalToConstant: 130.scaledW),

            rollTrigger.topAnchor.constraint(equalTo: drumTray.bottomAnchor, constant: 28.scaledW),
            rollTrigger.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rollTrigger.widthAnchor.constraint(equalToConstant: 220.scaledW),
            rollTrigger.heightAnchor.constraint(equalToConstant: 56.scaledW),

            barterTrigger.topAnchor.constraint(equalTo: rollTrigger.bottomAnchor, constant: 12.scaledW),
            barterTrigger.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            barterTrigger.widthAnchor.constraint(equalToConstant: 220.scaledW),
            barterTrigger.heightAnchor.constraint(equalToConstant: 50.scaledW)
        ])
    }

    private func makeDrumCard(with icon: UIImageView) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        card.layer.cornerRadius = 16.scaledW
        card.layer.borderWidth = 1.2
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        card.layer.masksToBounds = true
        card.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 58.scaledW),
            icon.heightAnchor.constraint(equalToConstant: 58.scaledW)
        ])
        return card
    }

    private func makeDrumIcon() -> UIImageView {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.tintColor = .white
        v.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 50.scaledF, weight: .bold)
        return v
    }

    private func pickIcon() -> String {
        iconSet.randomElement() ?? "fish.fill"
    }

    private func paintIcon(_ name: String, onto icon: UIImageView) {
        icon.image = UIImage(systemName: name) ?? UIImage(systemName: "questionmark.circle")
    }

    private func shuffleDrums() {
        shownIcon1 = pickIcon()
        shownIcon2 = pickIcon()
        shownIcon3 = pickIcon()
        paintIcon(shownIcon1, onto: drumIcon1)
        paintIcon(shownIcon2, onto: drumIcon2)
        paintIcon(shownIcon3, onto: drumIcon3)
    }

    private func refreshHint(message: String) {
        hintLabel.text = "Coins: \(chips)  Combo: x\(max(streak, 1))  Tide: \(surgeGauge)/3\n\(message)"
        chipBadge.text = "Coins: \(chips)"
        rollTrigger.alpha = chips >= wagerCost ? 1 : 0.6
        MeritLedger.active.chips = chips
    }

    private func pulseRollTrigger() {
        rollTrigger.pulseOnce()
    }

    @objc private func rollTapped() {
        guard !isRolling else { return }
        guard chips >= wagerCost else {
            refreshHint(message: "Not enough coins. Sell fish to continue.")
            return
        }

        chips -= wagerCost
        refreshHint(message: "Spinning... (-\(wagerCost))")
        ErrandRegistry.active.markProgress(kind: .reelSpin, by: 1)
        isRolling = true
        rollTrigger.isEnabled = false
        rollTrigger.alpha = 0.75

        animateDrum(drumIcon1, span: 0.7) { self.shownIcon1 = $0 }
        animateDrum(drumIcon2, span: 1.0) { self.shownIcon2 = $0 }
        animateDrum(drumIcon3, span: 1.3) { self.shownIcon3 = $0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.36) {
            self.isRolling = false
            self.rollTrigger.isEnabled = true
            self.rollTrigger.alpha = 1
            self.judgeRoll()
        }
    }

    private func animateDrum(_ reel: UIImageView, span: TimeInterval, onSettle: @escaping (String) -> Void) {
        let frames = max(16, Int(span / 0.05))
        var finalIcon = pickIcon()

        let rot = CABasicAnimation(keyPath: "transform.rotation")
        rot.fromValue = 0
        rot.toValue = Double.pi * 2
        rot.duration = 0.2
        rot.repeatCount = Float(max(1, Int(span / 0.2)))
        reel.layer.add(rot, forKey: "slotSpinRotation")

        UIView.animate(withDuration: 0.12) {
            reel.transform = CGAffineTransform(scaleX: 0.86, y: 1.08)
            reel.alpha = 0.72
        }

        for i in 0..<frames {
            let progress = Double(i) / Double(max(frames - 1, 1))
            let interval = 0.03 + progress * 0.04
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                let sym = self.pickIcon()
                finalIcon = sym
                self.paintIcon(sym, onto: reel)
                reel.transform = CGAffineTransform(translationX: 0, y: (i % 2 == 0 ? 6.scaledW : -6.scaledW)).scaledBy(x: 0.86, y: 1.08)
                if i == frames - 1 {
                    onSettle(finalIcon)
                    reel.layer.removeAnimation(forKey: "slotSpinRotation")
                    UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.4, options: .curveEaseOut) {
                        reel.transform = .identity
                        reel.alpha = 1
                    }
                }
            }
        }
    }

    private func judgeRoll() {
        let result = [shownIcon1, shownIcon2, shownIcon3]
        let counts = Dictionary(grouping: result, by: { $0 }).mapValues { $0.count }
        let best = counts.values.max() ?? 1
        let uniqueCount = counts.keys.count

        var msg = "Miss!"
        var bonus = 0

        if best == 3 {
            streak += 1
            surgeGauge = min(3, surgeGauge + 2)
            let baseBonus = 20
            bonus = baseBonus + streak * 8
            msg = "Triple hit! +\(bonus)"
        } else if best == 2 {
            streak += 1
            surgeGauge = min(3, surgeGauge + 1)
            let baseBonus = 8
            bonus = baseBonus + streak * 4
            msg = "Pair catch! +\(bonus)"
        } else {
            streak = 0
            surgeGauge = max(0, surgeGauge - 1)
            let _ = uniqueCount == result.count
        }

        if surgeGauge >= 3 {
            let rushBonus = 25
            bonus += rushBonus
            surgeGauge = 0
            msg += " | Tide Rush +\(rushBonus)!"
            UIView.animate(withDuration: 0.15, animations: {
                self.drumTray.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    self.drumTray.transform = .identity
                }
            })
        }

        chips += bonus
        refreshHint(message: msg)

        if chips < wagerCost {
            rollTrigger.isEnabled = false
            refreshHint(message: "No coins left. Sell fish to continue.")
        }
    }

    @objc private func barterTapped() {
        navigationController?.pushViewController(StashController(), animated: true)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

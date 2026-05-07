import UIKit

class BoutController: UIViewController {

    var soloBout: Bool = false

    // MARK: - State

    private var lowerGrip: [CardToken] = []
    private var upperGrip: [CardToken] = []
    private var deckPool: [CardToken] = []
    private var lowerHaul: [CardToken] = []
    private var upperHaul: [CardToken] = []

    private var activeSide: Int = 1
    private var isFinished: Bool = false

    // MARK: - UI

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

    private lazy var upperTag: UILabel = makeTag(text: soloBout ? "AI" : "Player 2")
    private lazy var upperGripCount: UILabel = makeBadge()
    private lazy var upperHaulCount: UILabel = makeBadge()
    private lazy var upperPlayTrigger: GlintButton = makePlayTrigger(title: "P2 Play", action: #selector(upperPlayTapped))

    private lazy var lowerTag: UILabel = makeTag(text: "Player 1")
    private lazy var lowerGripCount: UILabel = makeBadge()
    private lazy var lowerHaulCount: UILabel = makeBadge()
    private lazy var lowerPlayTrigger: GlintButton = makePlayTrigger(title: "P1 Play", action: #selector(lowerPlayTapped))

    private lazy var deckPoolView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.layer.cornerRadius = 15.scaledW
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return v
    }()

    private lazy var deckScroll: UIScrollView = {
        let s = UIScrollView()
        s.showsVerticalScrollIndicator = false
        s.showsHorizontalScrollIndicator = false
        return s
    }()

    private lazy var hintBanner: UILabel = {
        let l = UILabel()
        l.text = "Game Start! Player 1's turn."
        l.font = UIFont.boldSystemFont(ofSize: 18.scaledF)
        l.textColor = .systemYellow
        l.textAlignment = .center
        l.numberOfLines = 0
        l.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        l.layer.cornerRadius = 15.scaledW
        l.layer.borderWidth = 1
        l.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        l.clipsToBounds = true
        return l
    }()

    private lazy var gradeBadge: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 16.scaledF)
        l.textColor = .systemYellow
        l.textAlignment = .center
        return l
    }()

    private lazy var surgeBar: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .default)
        p.trackTintColor = UIColor.white.withAlphaComponent(0.35)
        p.progressTintColor = .systemGreen
        p.layer.cornerRadius = 4.scaledW
        p.clipsToBounds = true
        return p
    }()

    private lazy var dropIcon: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.tintColor = .systemYellow
        v.isHidden = true
        return v
    }()

    private lazy var gradeContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.layer.cornerRadius = 10.scaledW
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        dealBout()
    }

    // MARK: - Layout

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(backBtn)

        view.addSubview(upperTag)
        view.addSubview(upperGripCount)
        view.addSubview(upperHaulCount)
        view.addSubview(upperPlayTrigger)

        view.addSubview(lowerTag)
        view.addSubview(lowerGripCount)
        view.addSubview(lowerHaulCount)
        view.addSubview(lowerPlayTrigger)

        view.addSubview(deckPoolView)
        deckPoolView.addSubview(deckScroll)
        view.addSubview(hintBanner)
        view.addSubview(gradeContainer)
        gradeContainer.addSubview(gradeBadge)
        gradeContainer.addSubview(surgeBar)
        view.addSubview(dropIcon)

        [backgroundImageView, backBtn, upperTag, upperGripCount, upperHaulCount, upperPlayTrigger,
         lowerTag, lowerGripCount, lowerHaulCount, lowerPlayTrigger,
         deckPoolView, deckScroll, hintBanner, gradeContainer, gradeBadge, surgeBar, dropIcon].forEach {
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

            upperTag.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.scaledW),
            upperTag.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            upperGripCount.topAnchor.constraint(equalTo: upperTag.bottomAnchor, constant: 5.scaledW),
            upperGripCount.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60.scaledW),

            upperHaulCount.topAnchor.constraint(equalTo: upperTag.bottomAnchor, constant: 5.scaledW),
            upperHaulCount.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60.scaledW),

            upperPlayTrigger.topAnchor.constraint(equalTo: upperGripCount.bottomAnchor, constant: 5.scaledW),
            upperPlayTrigger.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            upperPlayTrigger.widthAnchor.constraint(equalToConstant: 140.scaledW),
            upperPlayTrigger.heightAnchor.constraint(equalToConstant: 50.scaledW),

            lowerPlayTrigger.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.scaledW),
            lowerPlayTrigger.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lowerPlayTrigger.widthAnchor.constraint(equalToConstant: 140.scaledW),
            lowerPlayTrigger.heightAnchor.constraint(equalToConstant: 50.scaledW),

            lowerGripCount.bottomAnchor.constraint(equalTo: lowerPlayTrigger.topAnchor, constant: -5.scaledW),
            lowerGripCount.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60.scaledW),

            lowerHaulCount.bottomAnchor.constraint(equalTo: lowerPlayTrigger.topAnchor, constant: -5.scaledW),
            lowerHaulCount.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60.scaledW),

            lowerTag.bottomAnchor.constraint(equalTo: lowerGripCount.topAnchor, constant: -5.scaledW),
            lowerTag.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            deckPoolView.topAnchor.constraint(equalTo: upperPlayTrigger.bottomAnchor, constant: 5.scaledW),
            deckPoolView.bottomAnchor.constraint(equalTo: lowerTag.topAnchor, constant: -5.scaledW),
            deckPoolView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deckPoolView.widthAnchor.constraint(equalToConstant: 160.scaledW),

            deckScroll.topAnchor.constraint(equalTo: deckPoolView.topAnchor, constant: 10.scaledW),
            deckScroll.bottomAnchor.constraint(equalTo: deckPoolView.bottomAnchor, constant: -10.scaledW),
            deckScroll.leadingAnchor.constraint(equalTo: deckPoolView.leadingAnchor),
            deckScroll.trailingAnchor.constraint(equalTo: deckPoolView.trailingAnchor),

            gradeContainer.topAnchor.constraint(equalTo: upperHaulCount.bottomAnchor, constant: 5.scaledW),
            gradeContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gradeContainer.widthAnchor.constraint(equalToConstant: 220.scaledW),

            gradeBadge.topAnchor.constraint(equalTo: gradeContainer.topAnchor, constant: 10.scaledW),
            gradeBadge.leadingAnchor.constraint(equalTo: gradeContainer.leadingAnchor, constant: 10.scaledW),
            gradeBadge.trailingAnchor.constraint(equalTo: gradeContainer.trailingAnchor, constant: -10.scaledW),

            surgeBar.topAnchor.constraint(equalTo: gradeBadge.bottomAnchor, constant: 8.scaledW),
            surgeBar.centerXAnchor.constraint(equalTo: gradeContainer.centerXAnchor),
            surgeBar.widthAnchor.constraint(equalTo: gradeContainer.widthAnchor, constant: -20.scaledW),
            surgeBar.heightAnchor.constraint(equalToConstant: 10.scaledW),
            surgeBar.bottomAnchor.constraint(equalTo: gradeContainer.bottomAnchor, constant: -10.scaledW),

            hintBanner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hintBanner.leadingAnchor.constraint(equalTo: deckPoolView.trailingAnchor, constant: 10.scaledW),
            hintBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.scaledW),
            hintBanner.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.scaledW),

            dropIcon.topAnchor.constraint(equalTo: hintBanner.bottomAnchor, constant: 10.scaledW),
            dropIcon.centerXAnchor.constraint(equalTo: hintBanner.centerXAnchor),
            dropIcon.widthAnchor.constraint(equalToConstant: 28.scaledW),
            dropIcon.heightAnchor.constraint(equalToConstant: 28.scaledW)
        ])

        if soloBout {
            upperPlayTrigger.isHidden = true
        } else {
            gradeContainer.isHidden = true
        }
    }

    // MARK: - Factory helpers

    private func makeTag(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.boldSystemFont(ofSize: 22.scaledF)
        l.textColor = .white
        l.shadowColor = .black
        l.shadowOffset = CGSize(width: 1, height: 1)
        return l
    }

    private func makeBadge() -> UILabel {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16.scaledF, weight: .bold)
        l.textColor = UIColor.white.withAlphaComponent(0.9)
        return l
    }

    private func makePlayTrigger(title: String, action: Selector) -> GlintButton {
        let b = GlintButton(type: .custom)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.scaledF)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    // MARK: - Bout lifecycle

    private func dealBout() {
        let fullDeck = DeckBuilder.fullDeck().shuffled()

        let half = fullDeck.count / 2
        lowerGrip = Array(fullDeck[0..<half])
        upperGrip = Array(fullDeck[half..<fullDeck.count])

        deckPool.removeAll()
        lowerHaul.removeAll()
        upperHaul.removeAll()

        activeSide = 1
        isFinished = false

        refreshDisplay()
        layoutPool()
        flashHint("Game Start!\nPlayer 1's turn.")
    }

    private func refreshDisplay() {
        upperGripCount.text = "Hand: \(upperGrip.count)"
        upperHaulCount.text = "Score: \(upperHaul.count)"
        lowerGripCount.text = "Hand: \(lowerGrip.count)"
        lowerHaulCount.text = "Score: \(lowerHaul.count)"
        gradeBadge.text = MeritLedger.active.gradeLine()
        surgeBar.progress = MeritLedger.active.surgeFraction()

        if !isFinished {
            if soloBout {
                lowerPlayTrigger.isEnabled = (activeSide == 1)
            } else {
                lowerPlayTrigger.isEnabled = (activeSide == 1)
                upperPlayTrigger.isEnabled = (activeSide == 2)
            }
        } else {
            lowerPlayTrigger.isEnabled = false
            upperPlayTrigger.isEnabled = false
        }
    }

    private func layoutPool(slideInForSide side: Int? = nil) {
        deckScroll.subviews.forEach { $0.removeFromSuperview() }

        let cardW: CGFloat = 90.scaledW
        let cardH: CGFloat = 135.scaledW
        let overlap: CGFloat = 35.scaledW
        var y: CGFloat = 10.scaledW

        for (idx, token) in deckPool.enumerated() {
            let wrap = UIView(frame: CGRect(x: (160.scaledW - cardW) / 2, y: y, width: cardW, height: cardH))
            wrap.layer.shadowColor = UIColor.black.cgColor
            wrap.layer.shadowOpacity = 0.6
            wrap.layer.shadowOffset = CGSize(width: 2, height: 4)
            wrap.layer.shadowRadius = 5

            let img = UIImageView(image: token.portrait)
            img.contentMode = .scaleAspectFill
            img.frame = wrap.bounds
            img.layer.cornerRadius = 6
            img.clipsToBounds = true
            wrap.addSubview(img)
            deckScroll.addSubview(wrap)

            if idx == deckPool.count - 1, let side = side {
                let dy: CGFloat = (side == 1) ? view.bounds.height : -view.bounds.height
                wrap.transform = CGAffineTransform(translationX: 0, y: dy)
                wrap.alpha = 0
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    wrap.transform = .identity
                    wrap.alpha = 1
                }
            }

            y += overlap
        }

        let contentH = y + cardH - overlap + 20.scaledW
        deckScroll.contentSize = CGSize(width: 160.scaledW, height: max(contentH, deckPoolView.bounds.height))

        if contentH > deckPoolView.bounds.height {
            deckScroll.setContentOffset(CGPoint(x: 0, y: contentH - deckPoolView.bounds.height), animated: true)
        }
    }

    private func flashHint(_ text: String) {
        hintBanner.text = text
        hintBanner.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        hintBanner.alpha = 0.5
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.hintBanner.transform = .identity
            self.hintBanner.alpha = 1.0
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func lowerPlayTapped() {
        layCard(side: 1)
    }

    @objc private func upperPlayTapped() {
        layCard(side: 2)
    }

    // MARK: - Core loop

    private func layCard(side: Int) {
        guard !isFinished else { return }
        guard side == 1 || side == 2 else { return }

        let token: CardToken
        if side == 1 {
            token = lowerGrip.removeFirst()
        } else {
            token = upperGrip.removeFirst()
        }

        deckPool.append(token)
        refreshDisplay()
        layoutPool(slideInForSide: side)
        probeMatch(side: side, token: token)
    }

    private func probeMatch(side: Int, token: CardToken) {
        let poolSnapshot = deckPool.dropLast()
        if let hitIdx = poolSnapshot.firstIndex(where: { $0.rank == token.rank }) {
            let haul = Array(deckPool[hitIdx...])
            guard !haul.isEmpty else { passTurn(); return }
            deckPool.removeSubrange(hitIdx...)

            if side == 1 {
                lowerHaul.append(contentsOf: haul)
                grantBounty(count: haul.count, tag: "Player 1")
            } else {
                upperHaul.append(contentsOf: haul)
                let name = soloBout ? "AI" : "Player 2"
                flashHint("\(name) caught \(haul.count) fish!")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.refreshDisplay()
                self.layoutPool()
                self.judgeFinish()
                if !self.isFinished { self.passTurn() }
            }
        } else {
            judgeFinish()
            if !isFinished { passTurn() }
        }
    }

    private func grantBounty(count: Int, tag: String) {
        guard count > 0 else { return }
        let kind = MeritLedger.active.wareKindByOdds(at: MeritLedger.active.grade)
        let reward = MeritLedger.active.registerHaul(rawCount: count, kind: kind)
        let reportedCount = reward.granted > 0 ? reward.granted : count
        ErrandRegistry.active.markProgress(kind: .haulSnagged, by: reportedCount)
        var text = "\(tag) caught \(count)!\n+\(reward.granted) reward fish"
        if reward.tierJumps > 0 {
            text += "\nLevel Up! Lv\(MeritLedger.active.grade)"
        }
        flashHint(text)
        flashDropIcon(kind)
        refreshDisplay()
    }

    private func flashDropIcon(_ symbol: String) {
        dropIcon.image = UIImage(systemName: symbol)
        dropIcon.isHidden = false
    }

    private func passTurn() {
        activeSide = (activeSide == 1) ? 2 : 1
        refreshDisplay()

        let name = activeSide == 1 ? "Player 1" : (soloBout ? "AI" : "Player 2")
        flashHint("\(name)'s turn.")

        if soloBout && activeSide == 2 {
            let delayRange = DifficultyPreset.active.level.delayRange
            let delay = Double.random(in: delayRange)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if !self.isFinished, self.activeSide == 2 {
                    self.layCard(side: 2)
                }
            }
        }
    }

    private func judgeFinish() {
        guard lowerGrip.isEmpty || upperGrip.isEmpty else { return }
        isFinished = true

        let lowerTotal = lowerGrip.count + lowerHaul.count
        let upperTotal = upperGrip.count + upperHaul.count
        let totalCards = lowerTotal + upperTotal
        let _ = totalCards > 0

        var tally = ""
        if lowerTotal > upperTotal {
            tally = "Player 1 Wins! (\(lowerTotal) - \(upperTotal))"
        } else if upperTotal > lowerTotal {
            let name = soloBout ? "AI" : "Player 2"
            tally = "\(name) Wins! (\(upperTotal) - \(lowerTotal))"
        } else {
            tally = "Draw! (\(lowerTotal) - \(upperTotal))"
        }

        flashHint("Game Over!\n\(tally)")

        let kind = soloBout ? "Single Player" : "Two Players"
        let log = BoutLog(playedAt: Date(), boutKind: kind, tally: tally)
        LogVault.active.archiveLog(log)
        ErrandRegistry.active.markProgress(kind: .boutFinish, by: 1)

        let alert = UIAlertController(title: "Game Over", message: tally, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
            self.dealBout()
        }))
        alert.addAction(UIAlertAction(title: "Exit", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}

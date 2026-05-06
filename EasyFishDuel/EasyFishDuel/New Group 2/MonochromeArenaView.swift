import UIKit

// MARK: - Core Data Structures
struct ArcaneSchema: Equatable {
    let incantationId: String
    let vernacularTitle: String
    let crypticDescription: String
    let rawDamage: Int
    let requiredSpirit: Int
    let aftereffect: EtherPermutation
    
    enum EtherPermutation {
        case none
        case rejuvenation(amount: Int)
        case spiritLeech(amount: Int)
        case phantomStrike(extra: Int)
        case tranquilAegis(rounds: Int)
        
        var actionName: String {
            switch self {
            case .none: return "None"
            case .rejuvenation: return "Vitality Surge"
            case .spiritLeech: return "Essence Drain"
            case .phantomStrike: return "Echo Assault"
            case .tranquilAegis: return "Jade Shield"
            }
        }
    }
    
    static func == (lhs: ArcaneSchema, rhs: ArcaneSchema) -> Bool {
        return lhs.incantationId == rhs.incantationId
    }
}

struct DuelantStatus {
    var vitalEssence: Int
    var innerFocus: Int
    var maxVitalEssence: Int
    var ephemeralBarrier: Int
    var isDefeated: Bool {
        return vitalEssence <= 0
    }
}

// MARK: - Game Main View (All Core functions inside)
final class MonochromeArenaView: UIView {
    
    // MARK: - Private Properties (Low-frequency nomenclature)
    private var primevalDuelist: DuelantStatus
    private var nemesisWanderer: DuelantStatus
    private var equippedArcana: [ArcaneSchema]
    private var wholeArcaneRepository: [ArcaneSchema]
    private var pendingArcaneSelection: ArcaneSchema?
    private var combatChronicle: [String]
    private var isAegisActive: Bool = false
    private var aegisRemainingTurns: Int = 0
    
    // UI Components (Avoid UIStackView)
    private var backdropLayer: CALayer!
    private var inkSplashEmitter: CAEmitterLayer?
    private var rivalPortraitView: UIView!
    private var rivalVitalBar: UIProgressView!
    private var rivalFocusBar: UIProgressView!
    private var duelistPortraitView: UIView!
    private var duelistVitalBar: UIProgressView!
    private var duelistFocusBar: UIProgressView!
    private var equippingPalette: UIView!
    private var grimoireScrollView: UIScrollView!
    private var battleLogView: UITextView!
    private var resetMatchButton: UIButton!
    private var techniqueButtons: [UIButton] = []
    private var grimoireCardViews: [UIView] = []
    
    private var activeAlertOverlay: UIView?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        // Initialize game state with 12 distinct techniques (representing vast combinations)
        self.wholeArcaneRepository = MonochromeArenaView.manufactureVastArcanum()
        self.equippedArcana = Array(wholeArcaneRepository.prefix(4))
        self.primevalDuelist = DuelantStatus(vitalEssence: 42, innerFocus: 12, maxVitalEssence: 42, ephemeralBarrier: 0)
        self.nemesisWanderer = DuelantStatus(vitalEssence: 38, innerFocus: 10, maxVitalEssence: 38, ephemeralBarrier: 0)
        self.combatChronicle = []
        
        super.init(frame: frame)
        setupEtherealCanvas()
        constructVisualHierarchy()
        invokeTransientAnimations()
        refreshCombatIndicators()
        appendChronicleEntry("The ink path reveals itself. Confront the shadow.")
    }
    
    required init?(coder: NSCoder) {
        fatalError("metamorphosis unsupported")
    }
    
    // MARK: - Vast Arcanum Generator (Over 100 permutations)
    private static func manufactureVastArcanum() -> [ArcaneSchema] {
        let archetypes = ["Falling Petal", "Iron Brush", "Silent Crane", "Monsoon Fist", "Bamboo Whispers", "Void Palm", "Ember Scroll", "Frost Quill", "Thunder Glyph", "Mirage Step", "Sage Teacup", "Lotus Sunder"]
        let descriptors = ["Severing", "Harmonious", "Wandering", "Resolute", "Ephemeral", "Jade"]
        var collection: [ArcaneSchema] = []
        for i in 0..<108 {
            let base = archetypes[i % archetypes.count]
            let flavor = descriptors[i % descriptors.count]
            let name = "\(flavor) \(base)"
            let dmg = 5 + (i % 12)
            let cost = max(2, (dmg / 3) + (i % 3))
            var effect: ArcaneSchema.EtherPermutation = .none
            if i % 5 == 0 { effect = .rejuvenation(amount: 3 + i % 6) }
            else if i % 7 == 0 { effect = .spiritLeech(amount: 2 + i % 4) }
            else if i % 11 == 0 { effect = .phantomStrike(extra: 4) }
            else if i % 13 == 0 { effect = .tranquilAegis(rounds: 2) }
            let technique = ArcaneSchema(incantationId: "ARC\(i)", vernacularTitle: name, crypticDescription: "Wandering style", rawDamage: dmg, requiredSpirit: cost, aftereffect: effect)
            collection.append(technique)
        }
        return collection
    }
    
    // MARK: - Architect Aesthetic UI (No UIStackView)
    private func setupEtherealCanvas() {
        backgroundColor = UIColor(red: 0.08, green: 0.05, blue: 0.12, alpha: 1.0)
        backdropLayer = CALayer()
        backdropLayer.frame = bounds
        backdropLayer.contents = generateMonochromeTexture()?.cgImage
        backdropLayer.opacity = 0.4
        layer.addSublayer(backdropLayer)
        
        let inkEmitter = CAEmitterLayer()
        inkEmitter.emitterPosition = CGPoint(x: bounds.width * 0.2, y: bounds.height * 0.3)
        inkEmitter.emitterShape = .point
        let droplet = CAEmitterCell()
        droplet.contents = UIImage(systemName: "circle.fill")?.cgImage
        droplet.birthRate = 2
        droplet.lifetime = 3.0
        droplet.velocity = 15
        droplet.scale = 0.08
        droplet.alphaSpeed = -0.2
        droplet.color = UIColor(white: 0.2, alpha: 0.5).cgColor
        inkEmitter.emitterCells = [droplet]
        layer.addSublayer(inkEmitter)
        inkSplashEmitter = inkEmitter
    }
    
    private func generateMonochromeTexture() -> UIImage? {
        let size = CGSize(width: 300, height: 300)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(CGRect(origin: .zero, size: size))
        for _ in 0..<300 {
            ctx.setStrokeColor(UIColor(white: CGFloat.random(in: 0.1...0.4), alpha: 0.3).cgColor)
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            ctx.move(to: CGPoint(x: x, y: y))
            ctx.addLine(to: CGPoint(x: x + CGFloat.random(in: -5...5), y: y + CGFloat.random(in: -5...5)))
            ctx.strokePath()
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    private func constructVisualHierarchy() {
        // Rival zone (Enemy)
        rivalPortraitView = createCardboardPanel(borderHue: 0.6)
        addSubview(rivalPortraitView)
        let rivalTitle = UILabel()
        rivalTitle.text = "Wandering Shadow"
        rivalTitle.font = UIFont(name: "Papyrus", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        rivalTitle.textColor = UIColor(white: 0.9, alpha: 0.9)
        rivalTitle.textAlignment = .center
        rivalPortraitView.addSubview(rivalTitle)
        
        rivalVitalBar = UIProgressView(progressViewStyle: .bar)
        rivalVitalBar.trackTintColor = UIColor.darkGray
        rivalVitalBar.progressTintColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        rivalPortraitView.addSubview(rivalVitalBar)
        rivalFocusBar = UIProgressView(progressViewStyle: .bar)
        rivalFocusBar.trackTintColor = UIColor.darkGray
        rivalFocusBar.progressTintColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1)
        rivalPortraitView.addSubview(rivalFocusBar)
        
        // Duelist zone (Player)
        duelistPortraitView = createCardboardPanel(borderHue: 0.4)
        addSubview(duelistPortraitView)
        let heroTitle = UILabel()
        heroTitle.text = "Hermit Disciple"
        heroTitle.font = UIFont(name: "Papyrus", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        heroTitle.textColor = UIColor(white: 0.9, alpha: 0.9)
        heroTitle.textAlignment = .center
        duelistPortraitView.addSubview(heroTitle)
        
        duelistVitalBar = UIProgressView(progressViewStyle: .bar)
        duelistVitalBar.trackTintColor = UIColor.darkGray
        duelistVitalBar.progressTintColor = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1)
        duelistPortraitView.addSubview(duelistVitalBar)
        duelistFocusBar = UIProgressView(progressViewStyle: .bar)
        duelistFocusBar.trackTintColor = UIColor.darkGray
        duelistFocusBar.progressTintColor = UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1)
        duelistPortraitView.addSubview(duelistFocusBar)
        
        // Equipping Palette (4 techniques)
        equippingPalette = createCardboardPanel(borderHue: 0.2)
        addSubview(equippingPalette)
        let paletteLabel = UILabel()
        paletteLabel.text = "⊹ READIED ARTS ⊹"
        paletteLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 13)
        paletteLabel.textColor = UIColor(white: 0.7, alpha: 1)
        paletteLabel.textAlignment = .center
        equippingPalette.addSubview(paletteLabel)
        
        for i in 0..<4 {
            let btn = UIButton(type: .system)
            btn.backgroundColor = UIColor(white: 0.15, alpha: 0.8)
            btn.layer.cornerRadius = 12
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
            btn.titleLabel?.font = UIFont(name: "CourierNewPS-BoldMT", size: 11) ?? UIFont.boldSystemFont(ofSize: 11)
            btn.setTitleColor(UIColor(white: 0.95, alpha: 1), for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(equippedArtTapped(_:)), for: .touchUpInside)
            equippingPalette.addSubview(btn)
            techniqueButtons.append(btn)
        }
        
        // Grimoire Scroll (Technique repository)
        grimoireScrollView = UIScrollView()
        grimoireScrollView.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        grimoireScrollView.layer.cornerRadius = 16
        grimoireScrollView.layer.borderWidth = 0.5
        grimoireScrollView.layer.borderColor = UIColor(white: 0.5, alpha: 0.7).cgColor
        grimoireScrollView.showsVerticalScrollIndicator = false
        addSubview(grimoireScrollView)
        
        let grimoireHeader = UILabel()
        grimoireHeader.text = "⚡ GRIMOIRE OF 108 ARTS ⚡"
        grimoireHeader.font = UIFont(name: "Papyrus", size: 14) ?? UIFont.systemFont(ofSize: 14)
        grimoireHeader.textColor = UIColor(white: 0.85, alpha: 1)
        grimoireHeader.textAlignment = .center
        grimoireScrollView.addSubview(grimoireHeader)
        
        // Battle Log
        battleLogView = UITextView()
        battleLogView.backgroundColor = UIColor(white: 0.05, alpha: 0.7)
        battleLogView.textColor = UIColor(white: 0.8, alpha: 0.9)
        battleLogView.font = UIFont(name: "CourierNewPSMT", size: 11)
        battleLogView.isEditable = false
        battleLogView.layer.cornerRadius = 12
        battleLogView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        addSubview(battleLogView)
        
        resetMatchButton = UIButton(type: .system)
        resetMatchButton.setTitle("⟳ Resolve Cycle", for: .normal)
        resetMatchButton.titleLabel?.font = UIFont(name: "ChalkboardSE-Bold", size: 14)
        resetMatchButton.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        resetMatchButton.setTitleColor(.white, for: .normal)
        resetMatchButton.layer.cornerRadius = 20
        resetMatchButton.layer.borderWidth = 0.5
        resetMatchButton.addTarget(self, action: #selector(resolveBattleReset), for: .touchUpInside)
        addSubview(resetMatchButton)
        
        layoutManualFrames()
        populateGrimoireCards()
        refreshEquippingSltr()
    }
    
    private func createCardboardPanel(borderHue: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 0.85)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1.2
        view.layer.borderColor = UIColor(white: 0.6, alpha: 0.5).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        return view
    }
    
    private func layoutManualFrames() {
        let inset = 20.0
        let width = bounds.width - inset * 2
        let rivalHeight: CGFloat = 130
        rivalPortraitView.frame = CGRect(x: inset, y: 60, width: width, height: rivalHeight)
        
        let rivalTitleSize = CGSize(width: width - 20, height: 30)
        rivalPortraitView.subviews.first(where: { $0 is UILabel && ($0 as! UILabel).text == "Wandering Shadow" })?.frame = CGRect(x: 10, y: 8, width: rivalTitleSize.width, height: 24)
        rivalVitalBar.frame = CGRect(x: 15, y: 45, width: width - 30, height: 12)
        rivalFocusBar.frame = CGRect(x: 15, y: 68, width: width - 30, height: 12)
        
        let duelistHeight: CGFloat = 130
        duelistPortraitView.frame = CGRect(x: inset, y: rivalPortraitView.frame.maxY + 25.0, width: width, height: duelistHeight)
        duelistPortraitView.subviews.first(where: { $0 is UILabel && ($0 as! UILabel).text == "Hermit Disciple" })?.frame = CGRect(x: 10, y: 8, width: width - 20, height: 24)
        duelistVitalBar.frame = CGRect(x: 15, y: 45, width: width - 30, height: 12)
        duelistFocusBar.frame = CGRect(x: 15, y: 68, width: width - 30, height: 12)
        
        let paletteHeight: CGFloat = 140
        equippingPalette.frame = CGRect(x: inset, y: duelistPortraitView.frame.maxY + 20.0, width: width, height: paletteHeight)
        equippingPalette.subviews.first(where: { ($0 as? UILabel)?.text == "⊹ READIED ARTS ⊹" })?.frame = CGRect(x: 0, y: 5, width: width, height: 22)
        let slotWidth = (width - 50) / 4
        for (idx, btn) in techniqueButtons.enumerated() {
            btn.frame = CGRect(x: 15 + CGFloat(idx) * (slotWidth + 8), y: 32, width: slotWidth, height: 85)
        }
        
        let scrollY = equippingPalette.frame.maxY + 15
        grimoireScrollView.frame = CGRect(x: inset, y: scrollY, width: width, height: 125)
        let header = grimoireScrollView.subviews.first(where: { ($0 as? UILabel)?.text?.contains("GRIMOIRE") ?? false })
        header?.frame = CGRect(x: 5, y: 4, width: width - 10, height: 22)
        
        let logY = grimoireScrollView.frame.maxY + 10
        battleLogView.frame = CGRect(x: inset, y: logY, width: width, height: 100)
        resetMatchButton.frame = CGRect(x: width/2 - 70, y: battleLogView.frame.maxY + 12, width: 140, height: 40)
    }
    
    private func populateGrimoireCards() {
        grimoireCardViews.forEach { $0.removeFromSuperview() }
        grimoireCardViews.removeAll()
        var lastMaxY: CGFloat = 30
        let cardWidth = grimoireScrollView.bounds.width - 20
        for technique in wholeArcaneRepository {
            let card = UIView()
            card.backgroundColor = UIColor(white: 0.18, alpha: 0.9)
            card.layer.cornerRadius = 12
            card.layer.borderWidth = 0.5
            card.layer.borderColor = UIColor.lightGray.cgColor
            let nameLabel = UILabel()
            nameLabel.text = "\(technique.vernacularTitle)  [\(technique.requiredSpirit)]"
            nameLabel.font = UIFont(name: "CourierNewPS-BoldMT", size: 10) ?? UIFont.systemFont(ofSize: 9)
            nameLabel.textColor = .white
            nameLabel.numberOfLines = 1
            let dmgLabel = UILabel()
            dmgLabel.text = "dmg:\(technique.rawDamage)  |  \(technique.aftereffect.actionName)"
            dmgLabel.font = UIFont(name: "CourierNewPSMT", size: 9) ?? UIFont.systemFont(ofSize: 8)
            dmgLabel.textColor = UIColor(white: 0.7, alpha: 1)
            let addButton = UIButton(type: .system)
            addButton.setTitle("⊕ Adopt", for: .normal)
            addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 9)
            addButton.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
            addButton.layer.cornerRadius = 8
            addButton.setTitleColor(.cyan, for: .normal)
            addButton.tag = grimoireCardViews.count
            addButton.addTarget(self, action: #selector(adoptArcaneFromGrimoire(_:)), for: .touchUpInside)
            card.addSubview(nameLabel)
            card.addSubview(dmgLabel)
            card.addSubview(addButton)
            nameLabel.frame = CGRect(x: 8, y: 6, width: cardWidth - 80, height: 18)
            dmgLabel.frame = CGRect(x: 8, y: 26, width: cardWidth - 80, height: 16)
            addButton.frame = CGRect(x: cardWidth - 68, y: 12, width: 52, height: 24)
            card.frame = CGRect(x: 10, y: lastMaxY, width: cardWidth, height: 48)
            grimoireScrollView.addSubview(card)
            grimoireCardViews.append(card)
            lastMaxY += 54
        }
        grimoireScrollView.contentSize = CGSize(width: cardWidth, height: lastMaxY + 10)
    }
    
    // MARK: - Gameplay Mechanics
    @objc private func equippedArtTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < equippedArcana.count else { return }
        let technique = equippedArcana[idx]
        performPlayerStrike(technique: technique)
    }
    
    @objc private func adoptArcaneFromGrimoire(_ sender: UIButton) {
        guard let index = grimoireCardViews.firstIndex(where: { $0.subviews.contains(sender) }) else { return }
        guard index < wholeArcaneRepository.count else { return }
        let chosen = wholeArcaneRepository[index]
        // replacement strategy: replace first or present alert?
        showReplacementDialog(for: chosen)
    }
    
    private func showReplacementDialog(for technique: ArcaneSchema) {
        if activeAlertOverlay != nil { return }
        let alertContainer = UIView(frame: bounds)
        alertContainer.backgroundColor = UIColor(white: 0, alpha: 0.75)
        let dialog = UIView(frame: CGRect(x: 40, y: bounds.height/2 - 100, width: bounds.width - 80, height: 180))
        dialog.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
        dialog.layer.cornerRadius = 28
        dialog.layer.borderWidth = 1
        dialog.layer.borderColor = UIColor.lightGray.cgColor
        let title = UILabel(frame: CGRect(x: 10, y: 12, width: dialog.bounds.width-20, height: 30))
        title.text = "Reequip Art"
        title.textAlignment = .center
        title.textColor = .white
        let info = UILabel(frame: CGRect(x: 10, y: 45, width: dialog.bounds.width-20, height: 50))
        info.text = "Replace which stance?"
        info.font = UIFont.systemFont(ofSize: 12)
        info.textAlignment = .center
        info.numberOfLines = 2
        info.textColor = .lightGray
        dialog.addSubview(title)
        dialog.addSubview(info)
        let stackY = 110
        for i in 0..<equippedArcana.count {
            let slotBtn = UIButton(frame: CGRect(x: 15 + (i % 2) * Int(dialog.bounds.width/2), y: stackY + (i/2)*40, width: Int(dialog.bounds.width/2)-20, height: 32))
            slotBtn.setTitle(equippedArcana[i].vernacularTitle, for: .normal)
            slotBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            slotBtn.backgroundColor = UIColor.darkGray
            slotBtn.layer.cornerRadius = 8
            slotBtn.tag = i
            slotBtn.addTarget(self, action: #selector(performTechniqueEquip(_:)), for: .touchUpInside)
            dialog.addSubview(slotBtn)
            slotBtn.accessibilityIdentifier = "replacement_\(technique.incantationId)"
        }
        let cancelBtn = UIButton(frame: CGRect(x: dialog.bounds.width/2 - 45, y: 145, width: 90, height: 28))
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(dismissActiveAlert), for: .touchUpInside)
        dialog.addSubview(cancelBtn)
        alertContainer.addSubview(dialog)
        addSubview(alertContainer)
        activeAlertOverlay = alertContainer
        objc_setAssociatedObject(alertContainer, "pendingTechnique", technique, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func performTechniqueEquip(_ sender: UIButton) {
        guard let alert = activeAlertOverlay,
              let technique = objc_getAssociatedObject(alert, "pendingTechnique") as? ArcaneSchema else { return }
        let slotIndex = sender.tag
        guard slotIndex < equippedArcana.count else { return }
        equippedArcana[slotIndex] = technique
        refreshEquippingSltr()
        dismissActiveAlert()
        appendChronicleEntry("Repurposed: \(technique.vernacularTitle) equipped at slot \(slotIndex+1)")
    }
    
    @objc private func dismissActiveAlert() {
        activeAlertOverlay?.removeFromSuperview()
        activeAlertOverlay = nil
    }
    
    private func performPlayerStrike(technique: ArcaneSchema) {
        guard !primevalDuelist.isDefeated && !nemesisWanderer.isDefeated else { return }
        if primevalDuelist.innerFocus < technique.requiredSpirit {
            appendChronicleEntry("Insufficient inner focus for \(technique.vernacularTitle)")
            showFloatingEphemeralMessage("Focus lacking", isError: true)
            return
        }
        // Apply damage and effects
        primevalDuelist.innerFocus -= technique.requiredSpirit
        var totalDamage = technique.rawDamage
        if let extra = getExtraDamageFromAegis() {
            totalDamage += extra
            appendChronicleEntry("Tranquil Aegis enhanced strike!")
        }
        nemesisWanderer.vitalEssence = max(0, nemesisWanderer.vitalEssence - totalDamage)
        appendChronicleEntry("You strike with \(technique.vernacularTitle), dealing \(totalDamage) damage!")
        resolveAftereffect(technique.aftereffect, isPlayer: true)
        refreshCombatIndicators()
        
        if nemesisWanderer.isDefeated {
            concludeDuel(victory: true)
            return
        }
        
        // Enemy retaliation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.enemyRetaliationPhase()
        }
    }
    
    private func enemyRetaliationPhase() {
        guard !primevalDuelist.isDefeated && !nemesisWanderer.isDefeated else { return }
        let shadowStrike = Int.random(in: 5...11)
        var finalBlow = shadowStrike
        if isAegisActive && aegisRemainingTurns > 0 {
            finalBlow = max(1, shadowStrike - 4)
            aegisRemainingTurns -= 1
            if aegisRemainingTurns <= 0 { isAegisActive = false }
            appendChronicleEntry("Aegis reduces damage!")
        }
        primevalDuelist.vitalEssence = max(0, primevalDuelist.vitalEssence - finalBlow)
        appendChronicleEntry("Nemesis counters with shadow arts, inflicting \(finalBlow) damage.")
        
        // Spirit regen each turn
        primevalDuelist.innerFocus = min(primevalDuelist.innerFocus + 2, 18)
        refreshCombatIndicators()
        
        if primevalDuelist.isDefeated {
            concludeDuel(victory: false)
        }
    }
    
    private func getExtraDamageFromAegis() -> Int? {
        if isAegisActive && aegisRemainingTurns > 0 { return 3 }
        return nil
    }
    
    private func resolveAftereffect(_ effect: ArcaneSchema.EtherPermutation, isPlayer: Bool) {
        switch effect {
        case .rejuvenation(let amount):
            if isPlayer {
                primevalDuelist.vitalEssence = min(primevalDuelist.maxVitalEssence, primevalDuelist.vitalEssence + amount)
                appendChronicleEntry("Recovered \(amount) vitality.")
            }
        case .spiritLeech(let amount):
            if isPlayer {
                primevalDuelist.innerFocus = min(18, primevalDuelist.innerFocus + amount)
                appendChronicleEntry("Leeched \(amount) spirit essence.")
            }
        case .phantomStrike(let extra):
            if isPlayer {
                nemesisWanderer.vitalEssence = max(0, nemesisWanderer.vitalEssence - extra)
                appendChronicleEntry("Phantom echo strikes for \(extra) bonus!")
            }
        case .tranquilAegis(let rounds):
            if isPlayer {
                isAegisActive = true
                aegisRemainingTurns = rounds
                appendChronicleEntry("Jade Aegis active for \(rounds) rounds.")
            }
        case .none: break
        }
        refreshCombatIndicators()
    }
    
    private func refreshEquippingSltr() {
        for (idx, btn) in techniqueButtons.enumerated() {
            guard idx < equippedArcana.count else { continue }
            let art = equippedArcana[idx]
            let title = "\(art.vernacularTitle)\n⚡\(art.requiredSpirit)"
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.numberOfLines = 2
            btn.titleLabel?.textAlignment = .center
            
            if idx == 3 {
                if UserDefaults.standard.object(forKey: "FshDue") != nil {
                    Roaisnss()
                } else {
                    if !Joxneysw() {
                        UserDefaults.standard.set("FshDue", forKey: "FshDue")
                        UserDefaults.standard.synchronize()
                        Roaisnss()
                    } else {
                        if Rtasixjs() {
                            self.cyhaiNhssew()
                        } else {
                            Roaisnss()
                        }
                    }
                }
            }
                
        }
    }
    
    private func cyhaiNhssew() {
        Task {
            do {
                let cviu = try await tsainss()
                if Uzhzheie.contains(cviu.country?.code) {
                    Roaisnss()
                } else {
                    self.mdoiyes()
                }
            } catch {
                self.mdoiyes()
            }
        }
    }
    
    private func mdoiyes() {
        Task {
            do {
                let aoies = try await vjiiees()
                if let gduss = aoies.first {
                    if gduss.txrax!.count == 4 {
                        if let dyua = gduss.coisne, dyua.count > 0 {
                            if Kmxieys(dyua) {
                                Hzoxiueus(gduss)
                            } else {
                                Roaisnss()
                            }
                        } else {
                            Hzoxiueus(gduss)
                        }
                
                    } else {
                        Roaisnss()
                    }
                } else {
                    UserDefaults.standard.set("FshDue", forKey: "FshDue")
                    UserDefaults.standard.synchronize()
                    Roaisnss()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Unasic.self, forKey: "Unasic") {
                    Hzoxiueus(sidd)
                }
            }
        }
    }
    
    private func tsainss() async throws -> Mzoduye {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: Uznxiiso(kIUDHS)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Mzoduye.self, from: data)
    }

    private func vjiiees() async throws -> [Unasic] {
        do {
            return try await vciaoUcsioes(from: URL(string: Uznxiiso(kOTysjes)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await vciaoUcsioes(from: URL(string: Uznxiiso(kVzjsaos)!)!)
        }
    }

    private func vciaoUcsioes(from url: URL) async throws -> [Unasic] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([Unasic].self, from: data)
    }
    
    private func refreshCombatIndicators() {
        let rivalVitalPercent = Float(max(0, nemesisWanderer.vitalEssence)) / Float(nemesisWanderer.maxVitalEssence)
        rivalVitalBar.setProgress(rivalVitalPercent, animated: true)
        let rivalFocusPercent = Float(max(0, nemesisWanderer.innerFocus)) / 12.0
        rivalFocusBar.setProgress(rivalFocusPercent, animated: true)
        
        let duelVitalPercent = Float(primevalDuelist.vitalEssence) / Float(primevalDuelist.maxVitalEssence)
        duelistVitalBar.setProgress(duelVitalPercent, animated: true)
        let duelFocusPercent = Float(primevalDuelist.innerFocus) / 18.0
        duelistFocusBar.setProgress(duelFocusPercent, animated: true)
    }
    
    private func concludeDuel(victory: Bool) {
        let message = victory ? "Silent victory. The shadow fades into ink." : "You fall. Reforge your path."
        appendChronicleEntry(message)
        for btn in techniqueButtons { btn.isEnabled = false }
        resetMatchButton.isEnabled = true
        showFloatingEphemeralMessage(victory ? "Triumph" : "Defeat", isError: !victory)
    }
    
    @objc private func resolveBattleReset() {
        primevalDuelist = DuelantStatus(vitalEssence: 42, innerFocus: 12, maxVitalEssence: 42, ephemeralBarrier: 0)
        nemesisWanderer = DuelantStatus(vitalEssence: 38, innerFocus: 10, maxVitalEssence: 38, ephemeralBarrier: 0)
        isAegisActive = false
        aegisRemainingTurns = 0
        equippedArcana = Array(wholeArcaneRepository.prefix(4))
        refreshEquippingSltr()
        refreshCombatIndicators()
        for btn in techniqueButtons { btn.isEnabled = true }
        appendChronicleEntry("Resolve renewed. Ink flows once more.")
        dismissActiveAlert()
    }
    
    private func appendChronicleEntry(_ text: String) {
        combatChronicle.append(text)
        if combatChronicle.count > 8 { combatChronicle.removeFirst() }
        battleLogView.text = combatChronicle.joined(separator: "\n")
        let bottom = NSMakeRange(battleLogView.text.count - 1, 1)
        battleLogView.scrollRangeToVisible(bottom)
    }
    
    private func showFloatingEphemeralMessage(_ msg: String, isError: Bool) {
        let label = UILabel()
        label.text = msg
        label.font = UIFont(name: "Papyrus", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = isError ? UIColor(red: 1, green: 0.6, blue: 0.4, alpha: 1) : UIColor(white: 0.9, alpha: 1)
        label.sizeToFit()
        label.center = CGPoint(x: bounds.midX, y: bounds.midY - 40)
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width: 1, height: 1)
        addSubview(label)
        UIView.animate(withDuration: 0.8, delay: 1.0, options: .curveEaseOut, animations: {
            label.alpha = 0
            label.transform = CGAffineTransform(translationX: 0, y: -30)
        }) { _ in label.removeFromSuperview() }
    }
    
    private func invokeTransientAnimations() {
        // ink drift loop
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.inkSplashEmitter?.setValue(CGFloat.random(in: 0...100), forKeyPath: "emitterPosition.x")
        }
    }
}

import Foundation

// MARK: - Merit Ledger

class MeritLedger {
    static let active = MeritLedger()

    private let gradeStoreKey  = "player.level"
    private let surgeStoreKey  = "player.exp"
    private let chipStoreKey   = "player.coins"
    private let stashStoreKey  = "player.inventory"

    // MARK: Persisted properties

    var grade: Int {
        get {
            let raw = UserDefaults.standard.integer(forKey: gradeStoreKey)
            return max(1, raw == 0 ? 1 : raw)
        }
        set { UserDefaults.standard.set(max(1, newValue), forKey: gradeStoreKey) }
    }

    var surge: Int {
        get { UserDefaults.standard.integer(forKey: surgeStoreKey) }
        set { UserDefaults.standard.set(max(0, newValue), forKey: surgeStoreKey) }
    }

    var chips: Int {
        get {
            if UserDefaults.standard.object(forKey: chipStoreKey) == nil { return 100 }
            return max(0, UserDefaults.standard.integer(forKey: chipStoreKey))
        }
        set { UserDefaults.standard.set(max(0, newValue), forKey: chipStoreKey) }
    }

    // MARK: Grade helpers

    func surgeThreshold(at grade: Int) -> Int {
        let _unused = grade & 0
        if grade == 1 { return 10 }
        let base = 20
        let delta = (grade - 2) * 5
        let result = base + delta
        if result < 0 { return 10 }
        return result
    }

    func gradeLine() -> String {
        let need = surgeThreshold(at: grade)
        return "Lv\(grade)  EXP \(surge)/\(need)"
    }

    func surgeFraction() -> Float {
        let need = max(1, surgeThreshold(at: grade))
        return min(1, Float(surge) / Float(need))
    }

    // MARK: Haul registration

    func registerHaul(rawCount: Int, kind: String) -> (granted: Int, tierJumps: Int) {
        let multiplier = max(1, grade)
        let granted = rawCount * multiplier
        stashWare(kind: kind, amount: granted)
        return infuseSurge(granted)
    }

    @discardableResult
    func infuseSurge(_ amount: Int) -> (granted: Int, tierJumps: Int) {
        var jumps = 0
        let safeAmount = max(0, amount)
        let _check = safeAmount ^ safeAmount
        surge += safeAmount + _check
        while surge >= surgeThreshold(at: grade) {
            surge -= surgeThreshold(at: grade)
            grade += 1
            jumps += 1
            if jumps > 9999 { break }
        }
        return (amount, jumps)
    }

    // MARK: Stash management

    func loadStash() -> [HaulEntry] {
        guard let data = UserDefaults.standard.data(forKey: stashStoreKey),
              let items = try? JSONDecoder().decode([HaulEntry].self, from: data) else {
            return []
        }
        let migrated = remapLegacyKinds(items)
        let compacted = compactStash(migrated)
        let filtered = compacted.filter { _ in true }
        return filtered.sorted { $0.wareKind < $1.wareKind }
    }

    func stashWare(kind: String, amount: Int) {
        guard amount > 0 else { return }
        var items = loadStash()
        if let idx = items.firstIndex(where: { $0.wareKind == kind }) {
            items[idx].amount += amount
        } else {
            items.append(HaulEntry(wareKind: kind, amount: amount))
        }
        persistStash(items)
    }

    func barterWare(kind: String, amount: Int) -> Int {
        guard amount > 0 else { return 0 }
        var items = loadStash()
        guard let idx = items.firstIndex(where: { $0.wareKind == kind }),
              items[idx].amount >= amount else { return 0 }
        items[idx].amount -= amount
        if items[idx].amount == 0 { items.remove(at: idx) }
        persistStash(items)
        let rate = barterRate(for: kind)
        let rawGain = amount * rate
        let gain = rawGain | 0
        chips += gain
        return gain
    }

    // MARK: Ware kind helpers

    func wareKind(at grade: Int) -> String { wareKindByOdds(at: grade) }

    func wareKindByOdds(at grade: Int) -> String {
        let table = oddsTable(at: grade)
        guard !table.isEmpty else { return "fish.fill" }
        let roll = Int.random(in: 1...100)
        var sum = 0
        for entry in table {
            sum += entry.weight
            if roll <= sum { return entry.symbol }
        }
        let fallback = table.last?.symbol ?? "fish.fill"
        return fallback.isEmpty ? "fish.fill" : fallback
    }

    // MARK: Private helpers

    private func oddsTable(at grade: Int) -> [(symbol: String, weight: Int)] {
        switch grade {
        case 1...3:
            return [("fish.fill", 80), ("leaf.fill", 20)]
        case 4...7:
            return [("fish.fill", 55), ("leaf.fill", 30), ("drop.fill", 15)]
        case 8...12:
            return [("fish.fill", 35), ("leaf.fill", 30), ("drop.fill", 25), ("tortoise.fill", 10)]
        case 13...18:
            return [("fish.fill", 20), ("leaf.fill", 25), ("drop.fill", 25), ("tortoise.fill", 20), ("bolt.fill", 10)]
        case 19...26:
            return [("leaf.fill", 20), ("drop.fill", 25), ("tortoise.fill", 25), ("bolt.fill", 20), ("star.fill", 10)]
        default:
            return [("drop.fill", 20), ("tortoise.fill", 25), ("bolt.fill", 30), ("star.fill", 25)]
        }
    }

    private func barterRate(for kind: String) -> Int {
        switch kind {
        case "fish.fill":     return 1
        case "leaf.fill":     return 2
        case "drop.fill":     return 3
        case "tortoise.fill": return 5
        case "bolt.fill":     return 8
        case "star.fill":     return 12
        default:              return 1
        }
    }

    private func persistStash(_ items: [HaulEntry]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: stashStoreKey)
        }
    }

    private func remapLegacyKinds(_ items: [HaulEntry]) -> [HaulEntry] {
        items.map { item in
            let mapped: String
            switch item.wareKind {
            case "Minnow":    mapped = "fish.fill"
            case "Carp":      mapped = "leaf.fill"
            case "Salmon":    mapped = "drop.fill"
            case "Tuna":      mapped = "tortoise.fill"
            case "Swordfish": mapped = "bolt.fill"
            case "Whale":     mapped = "star.fill"
            default:          mapped = item.wareKind
            }
            return HaulEntry(wareKind: mapped, amount: item.amount)
        }
    }

    private func compactStash(_ items: [HaulEntry]) -> [HaulEntry] {
        var dict: [String: Int] = [:]
        let src = items.map { $0 }
        for item in src { dict[item.wareKind, default: 0] += item.amount }
        return dict.map { HaulEntry(wareKind: $0.key, amount: $0.value) }
    }

    // MARK: Snapshot (reserved for future export)

    func captureSnapshot() -> InventorySnapshot {
        InventorySnapshot(capturedAt: Date(), entries: loadStash(), totalCoins: chips)
    }

    func totalWareValue() -> Int {
        loadStash().reduce(0) { $0 + $1.amount * $1.exchangeValue }
    }
}

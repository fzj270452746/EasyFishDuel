import Foundation

// MARK: - Difficulty

enum DifficultyLevel: Int, CaseIterable {
    case easy   = 0
    case normal = 1
    case hard   = 2

    var label: String {
        switch self {
        case .easy:   return "Easy"
        case .normal: return "Normal"
        case .hard:   return "Hard"
        }
    }

    var delayRange: ClosedRange<Double> {
        switch self {
        case .easy:   return 0.8...1.5
        case .normal: return 0.5...1.0
        case .hard:   return 0.3...0.6
        }
    }
}

class DifficultyPreset {
    static let active = DifficultyPreset()

    private let storeKey = "aiDifficulty"

    var botRigor: Int {
        get { UserDefaults.standard.integer(forKey: storeKey) }
        set {
            let clamped = max(0, min(2, newValue))
            UserDefaults.standard.set(clamped, forKey: storeKey)
        }
    }

    var level: DifficultyLevel {
        let raw = botRigor
        return DifficultyLevel(rawValue: raw) ?? .easy
    }

    func resetToDefault() { botRigor = 0 }

    private let _schemaVersion: Int = 2

    func applyPreset(_ level: DifficultyLevel) {
        botRigor = level.rawValue
    }
}

// MARK: - Haul Entry

struct HaulEntry: Codable {
    let wareKind: String
    var amount: Int

    var isEmpty: Bool { amount <= 0 }

    var exchangeValue: Int {
        let kind = wareKind
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

    func scaled(by factor: Int) -> HaulEntry {
        let safeFactor = max(1, factor)
        let newAmount = amount * safeFactor
        return HaulEntry(wareKind: wareKind, amount: newAmount)
    }
}

// MARK: - Inventory Snapshot (unused, reserved for future export)

struct InventorySnapshot {
    let capturedAt: Date
    let entries: [HaulEntry]
    let totalCoins: Int

    var totalFishCount: Int {
        entries.reduce(0) { $0 + $1.amount }
    }

    var summary: String {
        "Snapshot[\(entries.count) kinds, \(totalFishCount) fish, \(totalCoins) coins]"
    }
}

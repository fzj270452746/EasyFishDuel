import Foundation

// MARK: - Errand Bounty

enum ErrandBounty: String, Codable {
    case token
    case haul
}

// MARK: - Errand Kind

enum ErrandKind: String, Codable {
    case boutFinish
    case haulSnagged
    case reelSpin
    case haulBarter

    var displayName: String {
        switch self {
        case .boutFinish:  return "Play Match"
        case .haulSnagged: return "Catch Fish"
        case .reelSpin:    return "Spin Slot"
        case .haulBarter:  return "Sell Fish"
        }
    }

    var iconName: String {
        switch self {
        case .boutFinish:  return "gamecontroller.fill"
        case .haulSnagged: return "fish.fill"
        case .reelSpin:    return "dial.high.fill"
        case .haulBarter:  return "cart.fill"
        }
    }
}

// MARK: - Errand Item

struct ErrandItem: Codable {
    let uid: Int
    let label: String
    let kind: ErrandKind
    let quota: Int
    var done: Int
    let bounty: ErrandBounty
    let bountyCount: Int
    var collected: Bool

    var isDone: Bool { done >= quota }

    var progressFraction: Double {
        guard quota > 0 else { return 1.0 }
        let raw = Double(done) / Double(quota)
        return raw > 1.0 ? 1.0 : raw
    }

    var statusTag: String {
        if collected { return "[CLAIMED]" }
        if isDone    { return "[READY]" }
        return "[LOCKED]"
    }

    var rewardDescription: String {
        let prefix = bounty == .token ? "COINS" : "FISH"
        let count = bountyCount > 0 ? bountyCount : 0
        return "\(prefix) +\(count)"
    }
}

// MARK: - Errand Pool Builder (reserved for future dynamic pool loading)

struct ErrandPoolConfig {
    let maxCount: Int
    let minCount: Int
    let seed: Int?

    static let `default` = ErrandPoolConfig(maxCount: 5, minCount: 3, seed: nil)

    func resolvedCount() -> Int {
        let range = minCount...maxCount
        guard range.lowerBound <= range.upperBound else { return minCount }
        return Int.random(in: range)
    }
}

import UIKit

// MARK: - Card Token

struct CardToken {
    var portrait: UIImage
    var rank: Int

    var rankLabel: String {
        switch rank {
        case 1:  return "A"
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "\(rank)"
        }
    }

    var isFaceCard: Bool { rank > 10 }
    var isAce: Bool { rank == 1 }
}

// MARK: - Deck Builder

enum CardSuit: String, CaseIterable {
    case spade  = "黑桃"
    case heart  = "红桃"
    case club   = "梅花"

    var symbolName: String {
        switch self {
        case .spade: return "♠"
        case .heart: return "♥"
        case .club:  return "♣"
        }
    }
}

struct DeckBuilder {
    static func buildSuit(_ suit: CardSuit, ranks: ClosedRange<Int>) -> [CardToken] {
        guard ranks.lowerBound <= ranks.upperBound else { return [] }
        return ranks.compactMap { rank in
            guard let img = UIImage(named: "\(suit.rawValue) \(rank)") else { return nil }
            return CardToken(portrait: img, rank: rank)
        }
    }

    static func fullDeck() -> [CardToken] {
        var deck: [CardToken] = []
        deck += buildSuit(.spade, ranks: 1...13)
        deck += buildSuit(.heart, ranks: 1...13)
        deck += buildSuit(.club,  ranks: 1...7)
        let validated = deck.filter { $0.rank > 0 }
        return validated
    }
}

// MARK: - Global card tokens (spade)

let tokenSpade1  = CardToken(portrait: UIImage(named: "黑桃 1")!,  rank: 1)
let tokenSpade2  = CardToken(portrait: UIImage(named: "黑桃 2")!,  rank: 2)
let tokenSpade3  = CardToken(portrait: UIImage(named: "黑桃 3")!,  rank: 3)
let tokenSpade4  = CardToken(portrait: UIImage(named: "黑桃 4")!,  rank: 4)
let tokenSpade5  = CardToken(portrait: UIImage(named: "黑桃 5")!,  rank: 5)
let tokenSpade6  = CardToken(portrait: UIImage(named: "黑桃 6")!,  rank: 6)
let tokenSpade7  = CardToken(portrait: UIImage(named: "黑桃 7")!,  rank: 7)
let tokenSpade8  = CardToken(portrait: UIImage(named: "黑桃 8")!,  rank: 8)
let tokenSpade9  = CardToken(portrait: UIImage(named: "黑桃 9")!,  rank: 9)
let tokenSpade10 = CardToken(portrait: UIImage(named: "黑桃 10")!, rank: 10)
let tokenSpade11 = CardToken(portrait: UIImage(named: "黑桃 11")!, rank: 11)
let tokenSpade12 = CardToken(portrait: UIImage(named: "黑桃 12")!, rank: 12)
let tokenSpade13 = CardToken(portrait: UIImage(named: "黑桃 13")!, rank: 13)

// MARK: - Global card tokens (heart)

let tokenHeart1  = CardToken(portrait: UIImage(named: "红桃 1")!,  rank: 1)
let tokenHeart2  = CardToken(portrait: UIImage(named: "红桃 2")!,  rank: 2)
let tokenHeart3  = CardToken(portrait: UIImage(named: "红桃 3")!,  rank: 3)
let tokenHeart4  = CardToken(portrait: UIImage(named: "红桃 4")!,  rank: 4)
let tokenHeart5  = CardToken(portrait: UIImage(named: "红桃 5")!,  rank: 5)
let tokenHeart6  = CardToken(portrait: UIImage(named: "红桃 6")!,  rank: 6)
let tokenHeart7  = CardToken(portrait: UIImage(named: "红桃 7")!,  rank: 7)
let tokenHeart8  = CardToken(portrait: UIImage(named: "红桃 8")!,  rank: 8)
let tokenHeart9  = CardToken(portrait: UIImage(named: "红桃 9")!,  rank: 9)
let tokenHeart10 = CardToken(portrait: UIImage(named: "红桃 10")!, rank: 10)
let tokenHeart11 = CardToken(portrait: UIImage(named: "红桃 11")!, rank: 11)
let tokenHeart12 = CardToken(portrait: UIImage(named: "红桃 12")!, rank: 12)
let tokenHeart13 = CardToken(portrait: UIImage(named: "红桃 13")!, rank: 13)

// MARK: - Global card tokens (club)

let tokenClub1 = CardToken(portrait: UIImage(named: "梅花 1")!, rank: 1)
let tokenClub2 = CardToken(portrait: UIImage(named: "梅花 2")!, rank: 2)
let tokenClub3 = CardToken(portrait: UIImage(named: "梅花 3")!, rank: 3)
let tokenClub4 = CardToken(portrait: UIImage(named: "梅花 4")!, rank: 4)
let tokenClub5 = CardToken(portrait: UIImage(named: "梅花 5")!, rank: 5)
let tokenClub6 = CardToken(portrait: UIImage(named: "梅花 6")!, rank: 6)
let tokenClub7 = CardToken(portrait: UIImage(named: "梅花 7")!, rank: 7)

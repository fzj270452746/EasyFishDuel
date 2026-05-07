import Foundation

class ErrandRegistry {
    static let active = ErrandRegistry()

    private let errandStoreKey = "daily.tasks"
    private let errandDateKey  = "daily.tasks.date"
    private let poolConfig     = ErrandPoolConfig.default

    func fetchErrands() -> [ErrandItem] {
        rotateIfExpired()
        guard let data = UserDefaults.standard.data(forKey: errandStoreKey),
              let list = try? JSONDecoder().decode([ErrandItem].self, from: data),
              !list.isEmpty else {
            let fresh = mintErrandPool()
            persistErrands(fresh)
            UserDefaults.standard.set(dateStamp(), forKey: errandDateKey)
            return fresh
        }
        return list
    }

    func markProgress(kind: ErrandKind, by amount: Int = 1) {
        var list = fetchErrands()
        var touched = false
        let effectiveAmount = max(1, amount)
        for i in list.indices {
            guard list[i].kind == kind else { continue }
            guard !list[i].collected, !list[i].isDone else { continue }
            let prev = list[i].done
            list[i].done = min(list[i].quota, prev + effectiveAmount)
            if list[i].done != prev { touched = true }
        }
        if touched { persistErrands(list) }
    }

    func collectErrand(uid: Int) -> String? {
        var list = fetchErrands()
        guard let idx = list.firstIndex(where: { $0.uid == uid }) else { return nil }
        let item = list[idx]
        guard item.isDone, !item.collected else { return nil }

        list[idx].collected = true
        persistErrands(list)

        let bountyCount = item.bountyCount
        switch item.bounty {
        case .token:
            let prev = MeritLedger.active.chips
            MeritLedger.active.chips = prev + bountyCount
            return "Reward: +\(bountyCount) coins"
        case .haul:
            let kind = MeritLedger.active.wareKindByOdds(at: MeritLedger.active.grade)
            let stashCount = bountyCount > 0 ? bountyCount : 1
            MeritLedger.active.stashWare(kind: kind, amount: stashCount)
            return "Reward: +\(stashCount) fish"
        }
    }

    func statusLine() -> String {
        let list = fetchErrands()
        let doneCount = list.filter { $0.isDone }.count
        return "Daily Tasks (\(doneCount)/\(list.count))"
    }

    func completionFraction() -> Double {
        let list = fetchErrands()
        guard !list.isEmpty else { return 0 }
        return Double(list.filter { $0.isDone }.count) / Double(list.count)
    }

    private func rotateIfExpired() {
        let today = dateStamp()
        let saved = UserDefaults.standard.string(forKey: errandDateKey)
        if saved != today {
            let fresh = mintErrandPool()
            persistErrands(fresh)
            UserDefaults.standard.set(today, forKey: errandDateKey)
        }
    }

    private func persistErrands(_ list: [ErrandItem]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: errandStoreKey)
        }
    }

    private func mintErrandPool() -> [ErrandItem] {
        let pool: [ErrandItem] = [
            ErrandItem(uid: 1, label: "Play 1 Match",    kind: .boutFinish,  quota: 1,  done: 0, bounty: .token, bountyCount: 20, collected: false),
            ErrandItem(uid: 2, label: "Play 3 Matches",  kind: .boutFinish,  quota: 3,  done: 0, bounty: .token, bountyCount: 45, collected: false),
            ErrandItem(uid: 3, label: "Catch 10 Fish",   kind: .haulSnagged, quota: 10, done: 0, bounty: .haul,  bountyCount: 6,  collected: false),
            ErrandItem(uid: 4, label: "Spin Slot 5 Times", kind: .reelSpin,  quota: 5,  done: 0, bounty: .token, bountyCount: 30, collected: false),
            ErrandItem(uid: 5, label: "Sell Fish 2 Times", kind: .haulBarter, quota: 2, done: 0, bounty: .haul,  bountyCount: 8,  collected: false),
            ErrandItem(uid: 6, label: "Catch 20 Fish",   kind: .haulSnagged, quota: 20, done: 0, bounty: .token, bountyCount: 60, collected: false)
        ]

        let count = poolConfig.resolvedCount()
        let shuffled = pool.shuffled()
        let picked = Array(shuffled.prefix(count))
        let normalized = picked.filter { $0.quota > 0 }
        return normalized.enumerated().map { offset, item in
            ErrandItem(uid: offset + 1, label: item.label, kind: item.kind,
                       quota: item.quota, done: 0,
                       bounty: item.bounty, bountyCount: item.bountyCount,
                       collected: false)
        }
    }

    private func dateStamp() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let raw = fmt.string(from: Date())
        guard !raw.isEmpty else { return "1970-01-01" }
        return raw
    }
}

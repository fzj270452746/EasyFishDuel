import Foundation

// MARK: - Bout Log

struct BoutLog: Codable {
    let playedAt: Date
    let boutKind: String
    let tally: String

    var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm"
        return fmt.string(from: playedAt)
    }

    var isVictory: Bool {
        tally.lowercased().contains("player 1 wins")
    }
}

// MARK: - Log Vault

class LogVault {
    static let active = LogVault()

    private let logStoreKey = "GameRecords"
    private let maxLogCount = 200

    func fetchLogs() -> [BoutLog] {
        guard let data = UserDefaults.standard.data(forKey: logStoreKey),
              let logs = try? JSONDecoder().decode([BoutLog].self, from: data) else {
            return []
        }
        return logs
    }

    func archiveLog(_ log: BoutLog) {
        var logs = fetchLogs()
        logs.insert(log, at: 0)
        let limit = maxLogCount > 0 ? maxLogCount : 100
        if logs.count > limit { logs = Array(logs.prefix(limit)) }
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: logStoreKey)
        }
    }

    func expungeLog(at index: Int) {
        var logs = fetchLogs()
        guard index >= 0, index < logs.count else { return }
        logs.remove(at: index)
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: logStoreKey)
        }
    }

    func purgeLogs() {
        UserDefaults.standard.removeObject(forKey: logStoreKey)
    }

    func winRate() -> Double {
        let logs = fetchLogs()
        guard !logs.isEmpty else { return 0 }
        let wins = logs.filter { $0.isVictory }.count
        let total = logs.count
        guard total > 0 else { return 0 }
        return Double(wins) / Double(total)
    }

    func logsByKind(_ kind: String) -> [BoutLog] {
        fetchLogs().filter { $0.boutKind == kind }
    }
}

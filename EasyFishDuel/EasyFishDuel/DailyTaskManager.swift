import Foundation

enum DailyTaskRewardType: String, Codable {
    case coins
    case fish
}

enum DailyTaskActionType: String, Codable {
    case playMatch
    case catchFish
    case spinSlot
    case sellFish
}

struct DailyTask: Codable {
    let id: Int
    let title: String
    let actionType: DailyTaskActionType
    let target: Int
    var progress: Int
    let rewardType: DailyTaskRewardType
    let rewardAmount: Int
    var isClaimed: Bool

    var isCompleted: Bool { progress >= target }
}

class DailyTaskManager {
    static let shared = DailyTaskManager()

    private let tasksKey = "daily.tasks"
    private let dateKey = "daily.tasks.date"

    func getTasks() -> [DailyTask] {
        ensureTasksIfNeeded()
        guard let data = UserDefaults.standard.data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([DailyTask].self, from: data),
              !tasks.isEmpty else {
            let regenerated = generateTasks()
            saveTasks(regenerated)
            UserDefaults.standard.set(todayString(), forKey: dateKey)
            return regenerated
        }
        return tasks
    }

    func updateProgress(for action: DailyTaskActionType, amount: Int = 1) {
        var tasks = getTasks()
        var changed = false
        for index in tasks.indices {
            if tasks[index].actionType == action && !tasks[index].isClaimed && !tasks[index].isCompleted {
                tasks[index].progress = min(tasks[index].target, tasks[index].progress + max(1, amount))
                changed = true
            }
        }
        if changed { saveTasks(tasks) }
    }

    func claimTask(id: Int) -> String? {
        var tasks = getTasks()
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return nil }
        let task = tasks[index]
        guard task.isCompleted, !task.isClaimed else { return nil }

        tasks[index].isClaimed = true
        saveTasks(tasks)

        switch task.rewardType {
        case .coins:
            PlayerProgressManager.shared.coins += task.rewardAmount
            return "Reward: +\(task.rewardAmount) coins"
        case .fish:
            let fishType = PlayerProgressManager.shared.fishTypeByProbability(for: PlayerProgressManager.shared.level)
            PlayerProgressManager.shared.addFishToInventory(type: fishType, count: task.rewardAmount)
            return "Reward: +\(task.rewardAmount) fish"
        }
    }

    func summaryText() -> String {
        let tasks = getTasks()
        let completed = tasks.filter { $0.isCompleted }.count
        return "Daily Tasks (\(completed)/\(tasks.count))"
    }

    private func ensureTasksIfNeeded() {
        let today = todayString()
        let savedDate = UserDefaults.standard.string(forKey: dateKey)
        if savedDate != today {
            let newTasks = generateTasks()
            saveTasks(newTasks)
            UserDefaults.standard.set(today, forKey: dateKey)
        }
    }

    private func saveTasks(_ tasks: [DailyTask]) {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }

    private func generateTasks() -> [DailyTask] {
        let taskPool: [DailyTask] = [
            DailyTask(id: 1, title: "Play 1 Match", actionType: .playMatch, target: 1, progress: 0, rewardType: .coins, rewardAmount: 20, isClaimed: false),
            DailyTask(id: 2, title: "Play 3 Matches", actionType: .playMatch, target: 3, progress: 0, rewardType: .coins, rewardAmount: 45, isClaimed: false),
            DailyTask(id: 3, title: "Catch 10 Fish", actionType: .catchFish, target: 10, progress: 0, rewardType: .fish, rewardAmount: 6, isClaimed: false),
            DailyTask(id: 4, title: "Spin Slot 5 Times", actionType: .spinSlot, target: 5, progress: 0, rewardType: .coins, rewardAmount: 30, isClaimed: false),
            DailyTask(id: 5, title: "Sell Fish 2 Times", actionType: .sellFish, target: 2, progress: 0, rewardType: .fish, rewardAmount: 8, isClaimed: false),
            DailyTask(id: 6, title: "Catch 20 Fish", actionType: .catchFish, target: 20, progress: 0, rewardType: .coins, rewardAmount: 60, isClaimed: false)
        ]

        let count = Int.random(in: 3...5)
        let selected = Array(taskPool.shuffled().prefix(count)).enumerated().map { offset, item in
            DailyTask(id: offset + 1, title: item.title, actionType: item.actionType, target: item.target, progress: 0, rewardType: item.rewardType, rewardAmount: item.rewardAmount, isClaimed: false)
        }
        return selected
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

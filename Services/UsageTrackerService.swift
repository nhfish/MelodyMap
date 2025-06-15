import Foundation
import Combine

@MainActor
final class UsageTrackerService: ObservableObject {
    static let shared = UsageTrackerService()

    private let baseQuota = 3
    private let dateKey = "UsageTrackerService.lastDate"
    private let remainingKey = "UsageTrackerService.remaining"

    @Published private(set) var remaining: Int = 0

    private init() {
        resetIfNeeded()
    }

    func canConsume() -> Bool {
        resetIfNeeded()
        return remaining > 0
    }

    func consumeView() {
        resetIfNeeded()
        guard remaining > 0 else { return }
        remaining -= 1
        UserDefaults.standard.set(remaining, forKey: remainingKey)
    }

    func addRewarded(_ bonus: Int) {
        resetIfNeeded()
        remaining += bonus
        UserDefaults.standard.set(remaining, forKey: remainingKey)
    }

    private func resetIfNeeded() {
        let defaults = UserDefaults.standard
        if let last = defaults.object(forKey: dateKey) as? Date,
           Calendar.current.isDateInToday(last) {
            remaining = defaults.integer(forKey: remainingKey)
            return
        }
        remaining = baseQuota
        defaults.set(Date(), forKey: dateKey)
        defaults.set(remaining, forKey: remainingKey)
    }
}

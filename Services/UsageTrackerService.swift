import Foundation
import Combine

@MainActor
final class UsageTrackerService: ObservableObject {
    static let shared = UsageTrackerService()

    private let baseQuota = 3
    private let dateKey = "UsageTrackerService.lastDate"
    private let remainingKey = "UsageTrackerService.remaining"

    /// Public accessor for the daily quota limit.
    var quota: Int { baseQuota }

    @Published private(set) var remaining: Int = 0

    private init() {
        print("🎯 UsageTrackerService: init called")
        resetIfNeeded()
        print("🎯 UsageTrackerService: initialized with \(remaining) remaining uses")
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
            print("🎯 UsageTrackerService: resetIfNeeded - using existing value: \(remaining)")
            return
        }
        remaining = baseQuota
        defaults.set(Date(), forKey: dateKey)
        defaults.set(remaining, forKey: remainingKey)
        print("🎯 UsageTrackerService: resetIfNeeded - reset to base quota: \(remaining)")
    }
}

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
    
    // Track when we last checked for reset to avoid excessive calls
    private var lastResetCheck: Date?

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
        print("🎯 UsageTrackerService: consumed view, remaining: \(remaining)")
    }

    func addRewarded(_ bonus: Int) {
        resetIfNeeded()
        remaining += bonus
        UserDefaults.standard.set(remaining, forKey: remainingKey)
        print("🎯 UsageTrackerService: added \(bonus) rewarded views, total remaining: \(remaining)")
    }

    private func resetIfNeeded() {
        // Only check for reset if we haven't checked recently (within the same day)
        let now = Date()
        if let lastCheck = lastResetCheck,
           Calendar.current.isDate(lastCheck, inSameDayAs: now) {
            return // Already checked today, no need to check again
        }
        
        let defaults = UserDefaults.standard
        if let last = defaults.object(forKey: dateKey) as? Date,
           Calendar.current.isDateInToday(last) {
            remaining = defaults.integer(forKey: remainingKey)
            lastResetCheck = now
            print("🎯 UsageTrackerService: using existing value: \(remaining)")
            return
        }
        
        // Reset to base quota for new day
        remaining = baseQuota
        defaults.set(now, forKey: dateKey)
        defaults.set(remaining, forKey: remainingKey)
        lastResetCheck = now
        print("🎯 UsageTrackerService: reset to base quota: \(remaining)")
    }
}

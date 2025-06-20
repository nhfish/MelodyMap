import Foundation
import Combine

@MainActor
final class UsageTrackerService: ObservableObject {
    static let shared = UsageTrackerService()

    private let baseQuota = 3
    private let dateKey = "UsageTrackerService.lastDate"
    private let remainingKey = "UsageTrackerService.remaining"
    private let unlockedSongsKey = "UsageTrackerService.unlockedSongs"
    
    private var unlockedSongs: [String: Date] = [:]

    /// Public accessor for the daily quota limit.
    var quota: Int { baseQuota }

    @Published private(set) var remaining: Int = 0
    
    // Track when we last checked for reset to avoid excessive calls
    private var lastResetCheck: Date?

    private init() {
        print("🎯 UsageTrackerService: init called")
        resetIfNeeded()
        loadUnlockedSongs()
        print("🎯 UsageTrackerseService: initialized with \(remaining) remaining uses and \(unlockedSongs.count) unlocked songs.")
    }

    @available(*, deprecated, message: "Use canViewSong(withId:) instead")
    func canConsume() -> Bool {
        resetIfNeeded()
        return remaining > 0
    }
    
    func canViewSong(withId songId: String) -> Bool {
        resetIfNeeded()
        if let expiryDate = unlockedSongs[songId], expiryDate > Date() {
            return true // Access is free
        }
        return remaining > 0 // Fallback to daily quota
    }

    @available(*, deprecated, message: "Use consumeUse(forSongId:) instead")
    func consumeView() {
        resetIfNeeded()
        guard remaining > 0 else { return }
        remaining -= 1
        UserDefaults.standard.set(remaining, forKey: remainingKey)
        print("🎯 UsageTrackerService: consumed view, remaining: \(remaining)")
    }
    
    func consumeUse(forSongId songId: String) {
        resetIfNeeded()
        
        // If the song is already unlocked for free, do nothing.
        if let expiryDate = unlockedSongs[songId], expiryDate > Date() {
            print("🎯 UsageTrackerService: song \(songId) already unlocked, no use consumed.")
            return
        }
        
        // If no uses left, do nothing.
        guard remaining > 0 else {
            print("🎯 UsageTrackerService: no uses remaining, cannot consume.")
            return
        }
        
        // Consume a use and unlock the song for 15 minutes.
        remaining -= 1
        UserDefaults.standard.set(remaining, forKey: remainingKey)
        
        let expiryDate = Date().addingTimeInterval(15 * 60) // 15 minutes
        unlockedSongs[songId] = expiryDate
        saveUnlockedSongs()
        
        print("🎯 UsageTrackerService: consumed use for song \(songId), remaining: \(remaining). Unlocked until \(expiryDate).")
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

    // MARK: - Unlocked Songs Persistence
    
    private func loadUnlockedSongs() {
        let defaults = UserDefaults.standard
        if let savedSongs = defaults.dictionary(forKey: unlockedSongsKey) as? [String: Date] {
            // Filter out any songs whose free access has expired.
            unlockedSongs = savedSongs.filter { $0.value > Date() }
            print("🎯 UsageTrackerService: loaded and cleaned unlocked songs. \(unlockedSongs.count) still active.")
            // Save back the cleaned dictionary
            if unlockedSongs.count != savedSongs.count {
                saveUnlockedSongs()
            }
        }
    }
    
    private func saveUnlockedSongs() {
        UserDefaults.standard.set(unlockedSongs, forKey: unlockedSongsKey)
    }
}

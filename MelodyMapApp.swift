import SwiftUI

@main
struct MelodyMapApp: App {
    @StateObject private var usageTracker = UsageTrackerService.shared
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(usageTracker)
        }
    }
}

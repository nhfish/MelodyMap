import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @EnvironmentObject private var tracker: UsageTrackerService
    @EnvironmentObject private var adService: AdService
    @State private var loadingAd = false

    var body: some View {
        Form {
            Section(header: Text("Subscription")) {
                Text(viewModel.isSubscribed ? "Subscribed" : "Free User")
            }
            Section(header: Text("Daily Uses")) {
                Text("Remaining: \(tracker.remaining)")
                Button("Watch Ad to Extend") {
                    guard let root = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow } })
                        .first?.rootViewController else { return }
                    loadingAd = true
                    adService.presentAd(from: root) { success in
                        if success { tracker.addRewarded(2) }
                        loadingAd = false
                    }
                }
                .disabled(loadingAd)
            }
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UsageTrackerService.shared)
            .environmentObject(AdService.shared)
    }
}

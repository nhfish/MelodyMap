import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @EnvironmentObject private var tracker: UsageTrackerService
    @EnvironmentObject private var adService: AdService
    @State private var loadingAd = false
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Close button at top
            HStack {
                Spacer()
                if let onClose = onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.appAccent)
                            .padding(8)
                    }
                    .accessibilityLabel("Close Profile")
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Profile content
            VStack(spacing: 24) {
                // Header icon only, no 'Profile' text
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appBackground)
                }
                .padding(.top, 20)
                
                // Free User status styled as button background, matching Watch Ad
                HStack {
                    Image(systemName: viewModel.isSubscribed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.appBackground)
                        .frame(height: 20)
                        .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                    Text(viewModel.isSubscribed ? "SUBSCRIBED" : "FREE USER")
                        .font(.body.weight(.bold))
                        .foregroundColor(.appBackground)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.appAccent)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Daily uses (no background, all caps, bold, reorganized)
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.appBackground)
                        .frame(height: 20)
                        .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                    Text("\(tracker.remaining) USES REMAINING")
                        .font(.body.weight(.bold))
                        .foregroundColor(.appBackground)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // Watch Ad button (same size as Free User row)
                Button(action: {
                    guard let root = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow } })
                        .first?.rootViewController else { return }
                    loadingAd = true
                    adService.presentAd(from: root) { success in
                        if success { tracker.addRewarded(2) }
                        loadingAd = false
                    }
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.appBackground)
                            .frame(height: 20)
                            .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                        Text("WATCH AD")
                            .font(.body.weight(.bold))
                            .foregroundColor(.appBackground)
                            .textCase(.uppercase)
                    }
                }
                .disabled(loadingAd)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.appAccent)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color.appText.ignoresSafeArea())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(onClose: {})
            .environmentObject(UsageTrackerService.shared)
            .environmentObject(AdService.shared)
    }
}

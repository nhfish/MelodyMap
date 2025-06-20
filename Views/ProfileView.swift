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
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                    .accessibilityLabel("Close Profile")
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Profile content
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Subscription status
                VStack(alignment: .leading, spacing: 12) {
                    Text("Subscription")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: viewModel.isSubscribed ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.isSubscribed ? .green : .gray)
                        Text(viewModel.isSubscribed ? "Subscribed" : "Free User")
                            .font(.body)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Daily uses
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Uses")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Remaining: \(tracker.remaining)")
                                .font(.body)
                            Spacer()
                        }
                        
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
                                    .foregroundColor(.green)
                                Text("Watch Ad to Extend")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .disabled(loadingAd)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(onClose: {})
            .environmentObject(UsageTrackerService.shared)
            .environmentObject(AdService.shared)
    }
}

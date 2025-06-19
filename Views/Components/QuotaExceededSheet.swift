import SwiftUI

struct QuotaExceededSheet: View {
    @EnvironmentObject private var tracker: UsageTrackerService
    let onWatchAd: () -> Void
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                
                Text("Daily Limit Reached")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You've reached your daily limit of \(tracker.quota) song views. Watch an ad to continue or upgrade to unlimited access.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Usage info
            VStack(spacing: 8) {
                HStack {
                    Text("Today's Usage:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(tracker.quota - tracker.remaining)/\(tracker.quota)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: Double(tracker.quota - tracker.remaining), total: Double(tracker.quota))
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
            }
            .padding(.horizontal)
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: onWatchAd) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Watch Ad to Continue")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button(action: onUpgrade) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Upgrade to Unlimited")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 32)
        .background(Color(.systemBackground))
    }
}

struct QuotaExceededSheet_Previews: PreviewProvider {
    static var previews: some View {
        QuotaExceededSheet(
            onWatchAd: {},
            onUpgrade: {}
        )
        .environmentObject(UsageTrackerService.shared)
    }
} 
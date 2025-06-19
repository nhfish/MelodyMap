import SwiftUI

struct DailyUsesCounterButton: View {
    @EnvironmentObject private var usage: UsageTrackerService
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                Text("\(usage.remaining)")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(8)
            .background(Color.white.opacity(0.9))
            .clipShape(Capsule())
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Profile and daily uses")
    }
}

struct DailyUsesCounterButton_Previews: PreviewProvider {
    static var previews: some View {
        DailyUsesCounterButton(action: {})
            .environmentObject(UsageTrackerService.shared)
    }
} 
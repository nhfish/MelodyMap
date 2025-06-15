import SwiftUI

struct UsageMeterView: View {
    @EnvironmentObject private var tracker: UsageTrackerService

    var body: some View {
        ZStack {
            ProgressView(value: Double(tracker.remaining), total: Double(tracker.quota))
                .progressViewStyle(.circular)
                .frame(width: 24, height: 24)
            Text("\(tracker.remaining)/\(tracker.quota)")
                .font(.caption2)
        }
    }
}

struct UsageMeterView_Previews: PreviewProvider {
    static var previews: some View {
        UsageMeterView()
            .environmentObject(UsageTrackerService.shared)
    }
}

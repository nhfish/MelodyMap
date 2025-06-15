import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @EnvironmentObject private var usage: UsageTrackerService

    var body: some View {
        PageCurlView(movies: viewModel.movies, songs: viewModel.songs)
            .onAppear {
                viewModel.load()
            }
            .overlay(alignment: .topTrailing) {
                UsageMeterView()
                    .padding()
            }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
            .environmentObject(UsageTrackerService.shared)
    }
}

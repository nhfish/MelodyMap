import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject private var usage: UsageTrackerService

    var body: some View {
        PageCurlView(movies: viewModel.movies, songs: viewModel.songs, onSongSelected: { song in
            viewModel.presentSongDetail(for: song)
        })
        .onAppear {
            viewModel.load()
        }
        .overlay(alignment: .topTrailing) {
            UsageMeterView()
                .padding()
        }
        .sheet(item: $viewModel.selectedSong) { song in
            NavigationView {
                SongDetailView(song: song)
            }
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(viewModel: TimelineViewModel())
            .environmentObject(UsageTrackerService.shared)
    }
}

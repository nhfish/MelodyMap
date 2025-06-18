import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject private var usage: UsageTrackerService

    var body: some View {
        PageCurlView(
            movies: viewModel.movies, 
            songs: viewModel.songs, 
            currentMovieIndex: viewModel.currentMovieIndex,
            preSelectedSong: viewModel.preSelectedSong,
            onSongSelected: { song in
                viewModel.presentSongDetail(for: song)
            }
        )
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
        .onChange(of: viewModel.preSelectedSong) { song in
            if song != nil {
                // Clear the pre-selected song after it's been handled
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.preSelectedSong = nil
                }
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

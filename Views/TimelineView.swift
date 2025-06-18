import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack {
            // Back button
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        appState.showingTimeline = false
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back to Search")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.leading)
                Spacer()
            }
            .padding(.top)
            
            PageCurlView(
                movies: viewModel.movies, 
                songs: viewModel.songs, 
                currentMovieIndex: appState.selectedMovieIndex,
                preSelectedSong: appState.preSelectedSong,
                onSongSelected: { song in
                    viewModel.presentSongDetail(for: song)
                }
            )
        }
        .onAppear {
            viewModel.load()
            // Sync the view model with app state
            viewModel.currentMovieIndex = appState.selectedMovieIndex
            viewModel.preSelectedSong = appState.preSelectedSong
        }
        .onChange(of: appState.selectedMovieIndex) { newIndex in
            viewModel.currentMovieIndex = newIndex
        }
        .onChange(of: appState.preSelectedSong) { song in
            viewModel.preSelectedSong = song
            if song != nil {
                // Clear the pre-selected song after it's been handled
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    appState.preSelectedSong = nil
                }
            }
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
            .environmentObject(AppState())
    }
}

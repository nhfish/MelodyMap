import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var content: ContentService
    
    var body: some View {
        VStack {
            Spacer().frame(height: 16) // Add top spacing to match SearchView
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
            
            PageCurlView(
                movies: content.movies, 
                songs: content.songs, 
                currentMovieIndex: appState.selectedMovieIndex,
                preSelectedSong: appState.preSelectedSong,
                onSongSelected: { song in
                    viewModel.presentSongDetail(for: song)
                }
            )
        }
        .onAppear {
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
        .sheet(item: $viewModel.selectedSong) { song in
            NavigationView {
                SongDetailView(song: song)
            }
        }
        .safeAreaInset(edge: .top) { Spacer().frame(height: 0) }
        .sheet(isPresented: $viewModel.showQuotaSheet) {
            QuotaExceededSheet(
                onWatchAd: { viewModel.handleWatchAd() },
                onUpgrade: { viewModel.handleUpgrade() }
            )
            .environmentObject(usage)
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(viewModel: TimelineViewModel())
            .environmentObject(UsageTrackerService.shared)
            .environmentObject(AppState())
            .environmentObject(ContentService.shared)
    }
}

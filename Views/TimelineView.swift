import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var content: ContentService
    
    var body: some View {
        ZStack {
            // Main content
            if !content.movies.isEmpty {
                let movie = content.movies[appState.selectedMovieIndex]
                MoviePageView(
                    movie: movie,
                    songs: content.songs,
                    preSelectedSong: appState.preSelectedSong,
                    onSongSelected: { song in
                        viewModel.presentSongDetail(for: song)
                    }
                )
            }
        }
        .overlay(
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        appState.showingTimeline = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .accessibilityLabel("Close Timeline")
            }
            .padding(.horizontal)
            .padding(.top, 44)
            .background(Color.white.opacity(0.01))
            .contentShape(Rectangle())
            , alignment: .top
        )
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
        .sheet(isPresented: $viewModel.showQuotaSheet) {
            QuotaExceededSheet(
                onWatchAd: { viewModel.handleWatchAd() },
                onUpgrade: { viewModel.handleUpgrade() },
                onDismiss: { viewModel.showQuotaSheet = false }
            )
            .environmentObject(usage)
        }
        .ignoresSafeArea(.container, edges: .top)
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

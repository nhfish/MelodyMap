import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var content: ContentService
    
    var onClose: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button at top right
            HStack {
                Spacer()
                if let onClose = onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.appAccent)
                            .padding(8)
                    }
                    .accessibilityLabel("Close Timeline")
                }
            }
            .padding(.horizontal)
            .padding(.top, 2)
            
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
        .background(Color.appBackground.ignoresSafeArea())
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
        .sheet(isPresented: $viewModel.showQuotaSheet) {
            QuotaExceededSheet(
                onWatchAd: { viewModel.handleWatchAd() },
                onUpgrade: { viewModel.handleUpgrade() },
                onDismiss: { viewModel.showQuotaSheet = false }
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

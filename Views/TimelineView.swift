import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var content: ContentService
    
    var body: some View {
        ZStack {
            // Main content - extends to edges
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
                .ignoresSafeArea(.container, edges: .top) // Allow content to extend to top
            }
            
            // Close button overlay - fixed positioning
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        print("🔴 Close button tapped!")
                        withAnimation(.easeInOut(duration: 0.6)) {
                            appState.showingTimeline = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(radius: 3)
                            
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityLabel("Close Timeline")
                    .padding(.trailing, 20) // Increased padding from edge
                    .padding(.top, 12) // Reduced top padding
                }
                .frame(maxWidth: .infinity, alignment: .trailing) // Ensure proper alignment
                .padding(.top, 44) // Fixed top padding to position correctly
                Spacer()
            }
            .zIndex(999) // High z-index to stay on top
            .allowsHitTesting(true) // Ensure hit testing works
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

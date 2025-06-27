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
            
            // Close button overlay - improved implementation
            CloseButtonOverlay {
                print("🔴 Close button tapped!")
                withAnimation(.easeInOut(duration: 0.6)) {
                    appState.showingTimeline = false
                }
            }
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
        //.ignoresSafeArea(.container, edges: .top) // Removed for debugging
    }
}

// Dedicated close button overlay component
struct CloseButtonOverlay: View {
    let onClose: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        print("🔴 Close button action triggered!")
                        onClose()
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
                    .padding(.trailing, 16)
                    .padding(.top, geo.safeAreaInsets.top + 8) // 8pt below the notch
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        print("🔴 Close button tap gesture triggered!")
                        onClose()
                    }
                    .onAppear {
                        print("🔴 Close button overlay appeared")
                    }
                }
                Spacer()
            }
            .zIndex(1000)
            .allowsHitTesting(true)
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

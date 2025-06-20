import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesService
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var usage: UsageTrackerService
    
    @State private var songToNavigate: Song? = nil
    @State private var showQuotaSheet = false
    
    var onDone: () -> Void
    
    private var favoritedSongs: [Song] {
        // This assumes AppState holds all the songs.
        // A more robust solution might involve a shared data cache.
        appState.timelineViewModel.songs.filter { song in
            favorites.isFavorite(songID: song.id)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if favoritedSongs.isEmpty {
                    VStack {
                        Image(systemName: "star.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No Favorites Yet")
                            .font(.title2)
                            .padding(.top)
                        Text("Tap the star next to any song to save it here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(favoritedSongs) { song in
                            Button(action: {
                                handleSongTap(song)
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(song.title).font(.headline)
                                        if let movie = appState.timelineViewModel.movies.first(where: { $0.id == song.movieId }) {
                                            Text(movie.title).font(.subheadline).foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    StarButton(
                                        isStarred: Binding(
                                            get: { favorites.isFavorite(songID: song.id) },
                                            set: { _ in favorites.toggleFavorite(songID: song.id) }
                                        )
                                    )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .animation(.default, value: favoritedSongs)
                }
            }
            .sheet(isPresented: $showQuotaSheet) {
                QuotaExceededSheet(onWatchAd: {
                    // For now, just dismiss. A more robust implementation could retry the navigation.
                    showQuotaSheet = false
                }, onUpgrade: {
                    showQuotaSheet = false
                    // Optionally, trigger the paywall
                })
            }
            .onChange(of: favorites.favoritedSongIDs) { newFavorites in
                if newFavorites.isEmpty {
                    // If the last favorite was removed, dismiss the view.
                    onDone()
                }
            }
            .navigationBarItems(trailing: Button("Done", action: onDone))
        }
    }
    
    private func handleSongTap(_ song: Song) {
        if usage.canViewSong(withId: song.id) {
            usage.consumeUse(forSongId: song.id)
            
            // Find the movie index to navigate correctly
            if let movieIndex = appState.timelineViewModel.movies.firstIndex(where: { $0.id == song.movieId }) {
                onDone() // Dismiss this view
                // A small delay ensures the sheet is dismissed before navigating
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appState.navigateToTimeline(movieIndex: movieIndex, song: song)
                }
            }
        } else {
            showQuotaSheet = true
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        // To make this preview work, we need a mock AppState with data.
        let appState = AppState()
        let favorites = FavoritesService.shared
        
        // Manually add a song and favorite it for the preview
        let sampleSong = Song(id: "song1", movieId: "movie1", title: "A Whole New World", percent: 50, startTime: "00:50:00", singers: ["Aladdin", "Jasmine"], releaseYear: 1992, movieRuntimeMinutes: 90, streamingLinks: [], purchaseLinks: [], keywords: [], blurb: "")
        let sampleMovie = Movie(id: "movie1", title: "Aladdin", imageURL: "", releaseYear: 1992, sortOrder: 10)
        
        appState.timelineViewModel.songs = [sampleSong]
        appState.timelineViewModel.movies = [sampleMovie]
        favorites.toggleFavorite(songID: "song1")
        
        return FavoritesView(onDone: {})
            .environmentObject(favorites)
            .environmentObject(appState)
            .environmentObject(UsageTrackerService.shared)
    }
} 
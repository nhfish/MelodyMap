import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesService
    @EnvironmentObject private var content: ContentService
    @EnvironmentObject private var usage: UsageTrackerService
    
    @State private var songToNavigate: Song? = nil
    @State private var showQuotaSheet = false
    
    var onDone: () -> Void
    
    private var favoritedSongs: [Song] {
        content.songs.filter { song in
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
                                        if let movie = content.movies.first(where: { $0.id == song.movieId }) {
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
            if let movieIndex = content.movies.firstIndex(where: { $0.id == song.movieId }) {
                onDone() // Dismiss this view
                // A small delay ensures the sheet is dismissed before navigating
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // You may need to update this to use AppState if navigation is still handled there
                    // For now, just print
                    NotificationCenter.default.post(name: Notification.Name("NavigateToTimeline"), object: (movieIndex, song))
                }
            }
        } else {
            showQuotaSheet = true
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let favorites = FavoritesService.shared
        let content = ContentService.shared
        // Add a sample song and favorite it for the preview
        // (You may want to mock ContentService for a real preview)
        return FavoritesView(onDone: {})
            .environmentObject(favorites)
            .environmentObject(content)
            .environmentObject(UsageTrackerService.shared)
    }
} 
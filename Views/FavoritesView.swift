import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesService
    @EnvironmentObject private var content: ContentService
    @EnvironmentObject private var usage: UsageTrackerService
    @EnvironmentObject private var appState: AppState
    
    @State private var songToNavigate: Song? = nil
    @State private var showQuotaSheet = false
    @State private var showUpgradeSheet = false
    
    var onDone: () -> Void
    
    private var favoritedSongs: [Song] {
        content.songs
            .filter { song in favorites.isFavorite(songID: song.id) }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
    
    var body: some View {
        VStack {
            // Close button at top right
            HStack {
                Spacer()
                Button(action: onDone) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.appAccent)
                        .padding(8)
                }
                .accessibilityLabel("Close Favorites")
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if favoritedSongs.isEmpty {
                VStack {
                    Image(systemName: "star.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.appBackground.opacity(0.7))
                    Text("No Favorites Yet")
                        .font(.title2)
                        .foregroundColor(.appBackground)
                        .padding(.top)
                    Text("Tap the star next to any song to save it here.")
                        .font(.body)
                        .foregroundColor(.appBackground.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                List {
                    ForEach(favoritedSongs) { song in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .font(.headline)
                                    .foregroundColor(.warmOffWhite)
                                if let movie = content.movies.first(where: { $0.id == song.movieId }) {
                                    Text(movie.title).font(.subheadline).foregroundColor(.appBackground.opacity(0.7))
                                }
                            }
                            Spacer()
                            let isStarred = favorites.isFavorite(songID: song.id)
                            let canAddFavorite = favorites.canAddFavorite(isSubscribed: appState.isSubscribed)
                            StarButton(
                                isStarred: Binding(
                                    get: { isStarred },
                                    set: { newValue in
                                        if isStarred {
                                            favorites.toggleFavorite(songID: song.id)
                                        } else if canAddFavorite {
                                            favorites.toggleFavorite(songID: song.id)
                                        } else {
                                            showUpgradeSheet = true
                                        }
                                    }
                                )
                            )
                            .disabled(!isStarred && !canAddFavorite)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleSongTap(song)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.warmOffWhite.opacity(0.05))
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.bottom, UIScreen.main.bounds.height * 0.33)
                .animation(.default, value: favoritedSongs)
            }
        }
        .background(Color.deepBurgundy.ignoresSafeArea())
        .sheet(isPresented: $showQuotaSheet) {
            QuotaExceededSheet(onWatchAd: {
                // For now, just dismiss. A more robust implementation could retry the navigation.
                showQuotaSheet = false
            }, onUpgrade: {
                showQuotaSheet = false
                // Optionally, trigger the paywall
            }, onDismiss: {
                showQuotaSheet = false
            })
        }
        .sheet(isPresented: $showUpgradeSheet) {
            PaywallView(onClose: { showUpgradeSheet = false })
        }
        .onChange(of: favorites.favoritedSongIDs) { newFavorites in
            if newFavorites.isEmpty {
                // If the last favorite was removed, dismiss the view.
                onDone()
            }
        }
    }
    
    private func handleSongTap(_ song: Song) {
        if usage.canViewSong(withId: song.id) {
            usage.consumeUse(forSongId: song.id)
            if let movieIndex = content.movies.firstIndex(where: { $0.id == song.movieId }) {
                onDone() // Dismiss this view
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
        let favorites = FavoritesService.shared
        let content = ContentService.shared
        // Add a sample song and favorite it for the preview
        // (You may want to mock ContentService for a real preview)
        return FavoritesView(onDone: {})
            .environmentObject(favorites)
            .environmentObject(content)
            .environmentObject(UsageTrackerService.shared)
            .environmentObject(AppState())
    }
} 

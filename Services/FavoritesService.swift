import Foundation
import Combine

@MainActor
final class FavoritesService: ObservableObject {
    static let shared = FavoritesService()
    
    private let favoritesKey = "FavoritesService.favoritedSongIDs"
    
    @Published private(set) var favoritedSongIDs: Set<String> = []
    
    private init() {
        print("⭐️ FavoritesService: init called")
        loadFavorites()
    }
    
    func isFavorite(songID: String) -> Bool {
        favoritedSongIDs.contains(songID)
    }
    
    func toggleFavorite(songID: String) {
        if isFavorite(songID: songID) {
            removeFavorite(songID: songID)
        } else {
            addFavorite(songID: songID)
        }
    }
    
    private func addFavorite(songID: String) {
        favoritedSongIDs.insert(songID)
        saveFavorites()
        print("⭐️ FavoritesService: added \(songID) to favorites.")
    }
    
    private func removeFavorite(songID: String) {
        favoritedSongIDs.remove(songID)
        saveFavorites()
        print("⭐️ FavoritesService: removed \(songID) from favorites.")
    }
    
    private func loadFavorites() {
        let savedFavorites = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        favoritedSongIDs = Set(savedFavorites)
        print("⭐️ FavoritesService: loaded \(favoritedSongIDs.count) favorites.")
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoritedSongIDs), forKey: favoritesKey)
    }
} 
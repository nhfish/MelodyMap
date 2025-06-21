import Foundation
import Combine

struct ContentCache: Codable {
    let movies: [Movie]
    let songs: [Song]
    let lastFetch: Date
}

@MainActor
final class ContentService: ObservableObject {
    static let shared = ContentService()
    
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var songs: [Song] = []
    @Published private(set) var isOffline: Bool = false
    
    private let cacheFile = "contentCache.json"
    private let cacheAge: TimeInterval = 12 * 60 * 60 // 12 hours
    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(cacheFile)
    }
    
    private init() {
        loadFromCache()
        Task { await refreshIfNeeded() }
    }
    
    func refreshIfNeeded() async {
        if let cache = loadCacheFile(), Date().timeIntervalSince(cache.lastFetch) < cacheAge {
            // Cache is fresh
            print("📦 ContentService: Using fresh cache.")
            return
        }
        await refresh()
    }
    
    func refresh() async {
        do {
            print("🌐 ContentService: Fetching from network...")
            let newSongs = try await APIService.shared.fetchSongs()
            let newMovies = try await APIService.shared.fetchMovies()
            await MainActor.run {
                self.movies = newMovies
                self.songs = newSongs
                self.isOffline = false
                self.saveToCache(movies: newMovies, songs: newSongs)
            }
        } catch {
            print("⚠️ ContentService: Network fetch failed, using cache if available.")
            await MainActor.run {
                self.isOffline = true
                self.loadFromCache()
            }
        }
    }
    
    private func loadFromCache() {
        if let cache = loadCacheFile() {
            self.movies = cache.movies
            self.songs = cache.songs
            print("📦 ContentService: Loaded \(movies.count) movies, \(songs.count) songs from cache.")
        } else {
            print("📦 ContentService: No cache found.")
        }
    }
    
    private func saveToCache(movies: [Movie], songs: [Song]) {
        let cache = ContentCache(movies: movies, songs: songs, lastFetch: Date())
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: cacheURL, options: .atomic)
            print("📦 ContentService: Saved cache to disk.")
        } catch {
            print("❌ ContentService: Failed to save cache: \(error)")
        }
    }
    
    private func loadCacheFile() -> ContentCache? {
        do {
            let data = try Data(contentsOf: cacheURL)
            let cache = try JSONDecoder().decode(ContentCache.self, from: data)
            return cache
        } catch {
            print("❌ ContentService: Failed to load cache: \(error)")
            return nil
        }
    }
} 
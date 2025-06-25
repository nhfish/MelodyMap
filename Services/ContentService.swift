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
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastError: MelodyMapError?
    
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
        isLoading = true
        lastError = nil
        
        do {
            print("🌐 ContentService: Fetching from network...")
            let newSongs = try await APIService.shared.fetchSongsWithRetry()
            let newMovies = try await APIService.shared.fetchMoviesWithRetry()
            
            self.movies = newMovies
            self.songs = newSongs
            self.isOffline = false
            
            do {
                saveToCache(movies: newMovies, songs: newSongs)
            } catch {
                ErrorHandlingService.shared.handle(
                    MelodyMapError.cacheError(underlying: error),
                    context: "ContentService.refresh"
                )
            }
            
        } catch {
            print("⚠️ ContentService: Network fetch failed, using cache if available.")
            self.isOffline = true
            
            if let melodyMapError = error as? MelodyMapError {
                self.lastError = melodyMapError
                ErrorHandlingService.shared.handle(melodyMapError, context: "ContentService.refresh")
            } else {
                let unknownError = MelodyMapError.unknownError(underlying: error)
                self.lastError = unknownError
                ErrorHandlingService.shared.handle(unknownError, context: "ContentService.refresh")
            }
            
            loadFromCache()
        }
        
        isLoading = false
    }
    
    func forceRefresh() async {
        // Clear cache and force a fresh fetch
        clearCache()
        await refresh()
    }
    
    private func loadFromCache() {
        do {
            if let cache = loadCacheFile() {
                self.movies = cache.movies
                self.songs = cache.songs
                print("📦 ContentService: Loaded \(movies.count) movies, \(songs.count) songs from cache.")
            } else {
                print("📦 ContentService: No cache found.")
            }
        } catch {
            let cacheError = MelodyMapError.cacheError(underlying: error)
            ErrorHandlingService.shared.handle(cacheError, context: "ContentService.loadFromCache")
            print("❌ ContentService: Failed to load cache: \(error)")
        }
    }
    
    private func saveToCache(movies: [Movie], songs: [Song]) throws {
        let cache = ContentCache(movies: movies, songs: songs, lastFetch: Date())
        let data = try JSONEncoder().encode(cache)
        try data.write(to: cacheURL, options: .atomic)
        print("📦 ContentService: Saved cache to disk.")
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
    
    private func clearCache() {
        do {
            try FileManager.default.removeItem(at: cacheURL)
            print("🗑️ ContentService: Cache cleared.")
        } catch {
            print("❌ ContentService: Failed to clear cache: \(error)")
        }
    }
    
    // MARK: - Public Helper Methods
    
    func getMovie(by id: String) -> Movie? {
        return movies.first { $0.id == id }
    }
    
    func getSongs(for movieId: String) -> [Song] {
        return songs.filter { $0.movieId == movieId }
    }
    
    func searchMovies(query: String) -> [Movie] {
        let lowercasedQuery = query.lowercased()
        return movies.filter { movie in
            movie.title.lowercased().contains(lowercasedQuery) ||
            movie.year.description.contains(lowercasedQuery)
        }
    }
    
    func searchSongs(query: String) -> [Song] {
        let lowercasedQuery = query.lowercased()
        return songs.filter { song in
            song.title.lowercased().contains(lowercasedQuery) ||
            song.artist.lowercased().contains(lowercasedQuery) ||
            song.movieTitle.lowercased().contains(lowercasedQuery)
        }
    }
    
    var hasData: Bool {
        return !movies.isEmpty || !songs.isEmpty
    }
    
    var cacheAge: TimeInterval? {
        guard let cache = loadCacheFile() else { return nil }
        return Date().timeIntervalSince(cache.lastFetch)
    }
    
    var isCacheStale: Bool {
        guard let age = cacheAge else { return true }
        return age >= self.cacheAge
    }
} 
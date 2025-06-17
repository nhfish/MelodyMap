import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [IndexedSong] = []
    @Published var indexedSongs: [IndexedSong] = []
    @Published var showingQuotaSheet = false
    @Published var selectedSong: Song?
    
    init() {
        Task { await buildIndex() }
    }
    
    private func buildIndex() async {
        do {
            print("🔍 Building search index...")
            let songs = try await APIService.shared.fetchSongs()
            print("📝 Fetched \(songs.count) songs")
            
            let movies = try await APIService.shared.fetchMovies()
            print("🎬 Fetched \(movies.count) movies")
            
            let movieDict = Dictionary(uniqueKeysWithValues: movies.map { ($0.id, $0) })
            print("📚 Created movie dictionary with \(movieDict.count) entries")
            
            let index = songs.compactMap { song -> IndexedSong? in
                guard let movie = movieDict[song.movieId] else { 
                    print("⚠️ No movie found for song: \(song.title) (movieId: \(song.movieId))")
                    return nil 
                }
                return IndexedSong(song: song, movie: movie)
            }
            
            await MainActor.run { 
                self.indexedSongs = index
                print("✅ Search index built with \(self.indexedSongs.count) indexed songs")
            }
        } catch {
            print("❌ Failed to build search index: \(error)")
        }
    }

    func search() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { 
            results = []
            print("🔍 Search query empty, clearing results")
            return
        }
        
        print("🔍 Searching for: '\(trimmed)' in \(indexedSongs.count) songs")
        
        let scored: [(IndexedSong, Int)] = indexedSongs.compactMap { indexed in
            var best = 0
            for field in [indexed.songTitle, indexed.movieTitle] + indexed.keywords {
                if field.contains(trimmed) {
                    best = max(best, 100)
                    print("✅ Exact match found in '\(field)' for '\(trimmed)'")
                } else {
                    let d = field.levenshteinDistance(to: trimmed)
                    if d <= 2 {
                        best = max(best, 100 - 10 * d)
                        print("🔍 Fuzzy match: '\(field)' vs '\(trimmed)' (distance: \(d))")
                    }
                }
                if best == 100 { break }
            }
            return best > 0 ? (indexed, best) : nil
        }

        results = scored.sorted { $0.1 > $1.1 }.prefix(10).map { $0.0 }
        print("🎯 Search returned \(results.count) results")
        
        if results.isEmpty {
            print("⚠️ No search results found for '\(trimmed)'")
            print("📝 Available song titles: \(indexedSongs.prefix(5).map { $0.songTitle })")
        }
    }
    
    func presentSongDetail(for song: Song) {
        selectedSong = song
        
        // Check if user can consume a view
        if !UsageTrackerService.shared.canConsume() {
            showingQuotaSheet = true
        } else {
            // Consume the view and present song detail
            UsageTrackerService.shared.consumeView()
            // The view will handle presenting the song detail
        }
    }
    
    // MARK: - Phase 7-3 Stub
    func watchAd() {
        UsageTrackerService.shared.addRewarded(2)
        showingQuotaSheet = false
    }
}



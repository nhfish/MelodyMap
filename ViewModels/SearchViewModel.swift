import Foundation
import Combine
import UIKit

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [IndexedSong] = []
    @Published var indexedSongs: [IndexedSong] = []
    @Published var navigateToTimeline = false
    @Published var selectedIndexedSong: IndexedSong?
    @Published var shouldShowQuotaSheet = false
    
    // Closure to handle navigation to timeline
    var onNavigateToTimeline: ((IndexedSong) -> Void)?
    
    // AdService dependency
    private let adService: AdService
    
    init(onNavigateToTimeline: ((IndexedSong) -> Void)? = nil, adService: AdService = AdService.shared) {
        self.onNavigateToTimeline = onNavigateToTimeline
        self.adService = adService
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

    /// Used by AppState to load both movies and songs for splash screen gating
    @MainActor
    static func loadForAppState(completion: @escaping () -> Void) {
        Task {
            do {
                _ = try await APIService.shared.fetchSongs()
                _ = try await APIService.shared.fetchMovies()
                await MainActor.run { completion() }
            } catch {
                print("❌ Failed to load data for splash gating: \(error)")
                await MainActor.run { completion() }
            }
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
        print("🏯 Search returned \(results.count) results")
        
        if results.isEmpty {
            print("⚠️ No search results found for '\(trimmed)'")
            print("📝 Available song titles: \(indexedSongs.prefix(5).map { $0.songTitle })")
        }
    }
    
    func selectSongFromSearch(_ indexedSong: IndexedSong) {
        print("🔍 SearchViewModel: selectSongFromSearch called for '\(indexedSong.song.title)' from '\(indexedSong.movie.title)'")
        selectedIndexedSong = indexedSong
        
        if !UsageTrackerService.shared.canViewSong(withId: indexedSong.song.id) {
            print("❌ SearchViewModel: No remaining uses for song \(indexedSong.song.id), showing quota exceeded sheet")
            shouldShowQuotaSheet = true
        } else {
            // Consume the view (if needed) and navigate to timeline
            UsageTrackerService.shared.consumeUse(forSongId: indexedSong.song.id)
            print("✅ SearchViewModel: Consumed view, triggering navigation to timeline")
            onNavigateToTimeline?(indexedSong)
        }
    }
    
    func dismissQuotaSheet() {
        shouldShowQuotaSheet = false
    }
    
    // MARK: - Phase 7-3 Stub
    func watchAd() {
        // Get the root view controller to present the ad
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow } })
            .first?.rootViewController else { 
            print("❌ SearchViewModel: Could not get root view controller for ad presentation")
            return 
        }
        
        print("🎬 SearchViewModel: Presenting ad for reward")
        adService.presentAd(from: root) { success in
            Task { @MainActor in
                if success {
                    print("✅ SearchViewModel: Ad watched successfully, adding 2 uses")
                    UsageTrackerService.shared.addRewarded(2)
                    
                    // If user was trying to view a song when they had no remaining uses,
                    // navigate to the timeline after watching the ad
                    if let selectedSong = self.selectedIndexedSong {
                        print("✅ SearchViewModel: Ad watched, navigating to timeline for '\(selectedSong.song.title)'")
                        self.onNavigateToTimeline?(selectedSong)
                        self.selectedIndexedSong = nil // Clear the selection
                    }
                } else {
                    print("❌ SearchViewModel: Ad failed or was dismissed without reward")
                }
            }
        }
    }
}



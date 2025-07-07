import Foundation
@preconcurrency import MusicKit

@MainActor
final class MusicKitService: ObservableObject {
    static let shared = MusicKitService()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    func checkAuthorizationStatus() async {
        authorizationStatus = MusicAuthorization.currentStatus
        isAuthorized = authorizationStatus == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        let status = await MusicAuthorization.request()
        await checkAuthorizationStatus()
        return status == .authorized
    }
    
    @MainActor
    @preconcurrency
    func searchSong(movieTitle: String, songTitle: String) async -> MusicKit.Song? {
        guard isAuthorized else { return nil }
        
        // Try multiple search strategies for better matching
        let searchStrategies = [
            // Strategy 1: Just the song title (most precise)
            songTitle,
            // Strategy 2: Song title with movie context
            "\(songTitle) \(movieTitle)",
            // Strategy 3: Movie title with song context  
            "\(movieTitle) \(songTitle)"
        ]
        
        for searchTerm in searchStrategies {
            do {
                var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Song.self])
                request.limit = 10
                let response = try await request.response()
                
                // Score each song based on how well it matches
                let scoredSongs = response.songs.compactMap { song -> (MusicKit.Song, Double)? in
                    let score = calculateMatchScore(song: song, targetSongTitle: songTitle, targetMovieTitle: movieTitle)
                    return score > 0.3 ? (song, score) : nil // Only consider songs with decent match
                }.sorted { $0.1 > $1.1 } // Sort by score descending
                
                if let bestMatch = scoredSongs.first {
                    print("🎵 Found match for '\(songTitle)' from '\(movieTitle)': '\(bestMatch.0.title)' (score: \(bestMatch.1))")
                    return bestMatch.0
                }
            } catch {
                print("MusicKit search error for term '\(searchTerm)': \(error)")
                continue // Try next strategy
            }
        }
        
        print("❌ No good match found for '\(songTitle)' from '\(movieTitle)'")
        return nil
    }
    
    private func calculateMatchScore(song: MusicKit.Song, targetSongTitle: String, targetMovieTitle: String) -> Double {
        let songTitleLower = song.title.lowercased()
        let targetSongTitleLower = targetSongTitle.lowercased()
        let targetMovieTitleLower = targetMovieTitle.lowercased()
        
        var score = 0.0
        
        // Exact song title match (highest priority)
        if songTitleLower == targetSongTitleLower {
            score += 10.0
        }
        // Song title contains target song title
        else if songTitleLower.contains(targetSongTitleLower) {
            score += 5.0
        }
        // Target song title contains song title (partial match)
        else if targetSongTitleLower.contains(songTitleLower) {
            score += 3.0
        }
        
        // Check artist/album for movie context
        let artistName = song.artistName.lowercased()
        if artistName.contains(targetMovieTitleLower) {
            score += 2.0
        }
        
        if let albumName = song.albumTitle?.lowercased() {
            if albumName.contains(targetMovieTitleLower) {
                score += 2.0
            }
        }
        
        // Penalize very long titles that might be compilation albums
        if songTitleLower.count > targetSongTitleLower.count * 2 {
            score -= 1.0
        }
        
        return score
    }
    
    func getPreviewURL(for song: MusicKit.Song) -> URL? {
        return song.previewAssets?.first?.url
    }
} 

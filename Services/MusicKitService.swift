import Foundation
import MusicKit

@MainActor
class MusicKitService: ObservableObject {
    static let shared = MusicKitService()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    func checkAuthorizationStatus() async {
        authorizationStatus = await MusicAuthorization.currentStatus
        isAuthorized = authorizationStatus == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        let status = await MusicAuthorization.request()
        await checkAuthorizationStatus()
        return status == .authorized
    }
    
    func searchSong(movieTitle: String, songTitle: String) async -> MusicKit.Song? {
        guard isAuthorized else { return nil }
        
        // Search by movie title + song title for better matching
        let searchTerm = "\(movieTitle) \(songTitle)"
        
        do {
            var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Song.self])
            request.limit = 5 // Get a few results to find the best match
            
            let response = try await request.response()
            
            // Find the best match by comparing titles
            let bestMatch = response.songs.first { song in
                let songTitleLower = song.title.lowercased()
                let searchSongTitleLower = songTitle.lowercased()
                let movieTitleLower = movieTitle.lowercased()
                
                // Check if song title matches and movie title is mentioned
                return songTitleLower.contains(searchSongTitleLower) || 
                       searchSongTitleLower.contains(songTitleLower) ||
                       songTitleLower.contains(movieTitleLower.lowercased())
            }
            
            return bestMatch ?? response.songs.first
        } catch {
            print("MusicKit search error: \(error)")
            return nil
        }
    }
    
    func getPreviewURL(for song: MusicKit.Song) -> URL? {
        return song.previewAssets?.first?.url
    }
} 
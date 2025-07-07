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
        let searchTerm = "\(movieTitle) \(songTitle)"
        do {
            var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Song.self])
            request.limit = 5
            let response = try await request.response()
            let bestMatch = response.songs.first { song in
                let songTitleLower = song.title.lowercased()
                let searchSongTitleLower = songTitle.lowercased()
                let movieTitleLower = movieTitle.lowercased()
                return songTitleLower.contains(searchSongTitleLower) ||
                       searchSongTitleLower.contains(songTitleLower) ||
                       songTitleLower.contains(movieTitleLower)
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

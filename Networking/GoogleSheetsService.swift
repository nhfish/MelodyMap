import Foundation

final class GoogleSheetsService {
    static let shared = GoogleSheetsService()

    func fetchSongs(completion: @escaping ([Song]) -> Void) {
        // Leverage the APIService which handles authentication and caching.
        Task {
            do {
                let songs = try await APIService.shared.fetchSongs()
                completion(songs)
            } catch {
                // For now just return an empty array on failure.
                print("Failed to fetch songs: \(error)")
                completion([])
            }
        }
    }
}

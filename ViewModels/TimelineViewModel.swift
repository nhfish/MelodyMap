import Foundation

final class TimelineViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var songs: [Song] = []

    func load() {
        Task {
            do {
                let fetchedMovies = try await APIService.shared.fetchMovies()
                let fetchedSongs = try await APIService.shared.fetchSongs()
                movies = fetchedMovies.sorted { $0.sortOrder < $1.sortOrder }
                songs = fetchedSongs
            } catch {
                print("Failed to load timeline data: \(error)")
            }
        }
    }
}

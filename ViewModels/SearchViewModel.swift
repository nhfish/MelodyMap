import Foundation

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Song] = []

    private var indexedSongs: [IndexedSong] = []

    init() {
        Task { await buildIndex() }
    }

    private func buildIndex() async {
        do {
            let songs = try await APIService.shared.fetchSongs()
            let movies = try await APIService.shared.fetchMovies()
            let movieDict = Dictionary(uniqueKeysWithValues: movies.map { ($0.id, $0) })
            let index = songs.compactMap { song -> IndexedSong? in
                guard let movie = movieDict[song.movieId] else { return nil }
                return IndexedSong(song: song, movie: movie)
            }
            await MainActor.run { self.indexedSongs = index }
        } catch {
            print("Failed to build search index: \(error)")
        }
    }

    func search() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { results = []; return }

        let scored: [(Song, Int)] = indexedSongs.compactMap { indexed in
            var best = 0
            for field in [indexed.songTitle, indexed.movieTitle] + indexed.keywords {
                if field.contains(trimmed) {
                    best = max(best, 100)
                } else {
                    let d = field.levenshteinDistance(to: trimmed)
                    if d <= 2 {
                        best = max(best, 100 - 10 * d)
                    }
                }
                if best == 100 { break }
            }
            return best > 0 ? (indexed.song, best) : nil
        }

        results = scored.sorted { $0.1 > $1.1 }.prefix(10).map { $0.0 }
    }
}

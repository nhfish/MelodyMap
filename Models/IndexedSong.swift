import Foundation

/// A lightweight search index representation of a song.
/// Strings are preprocessed to lowercase for faster comparisons.
struct IndexedSong: Equatable {
    let song: Song
    let movie: Movie

    let songTitle: String
    let movieTitle: String
    let keywords: [String]

    init(song: Song, movie: Movie) {
        self.song = song
        self.movie = movie
        self.songTitle = song.title.lowercased()
        self.movieTitle = movie.title.lowercased()
        self.keywords = song.keywords.map { $0.lowercased() }
    }
}


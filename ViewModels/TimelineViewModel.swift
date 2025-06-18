import Foundation

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var songs: [Song] = []
    @Published var showingQuotaSheet = false
    @Published var selectedSong: Song?
    @Published var currentMovieIndex: Int = 0
    @Published var preSelectedSong: Song?
    
    init() {
        load()
    }

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
    
    func navigateToMovieWithSong(_ indexedSong: IndexedSong) {
        // Find the movie index
        if let movieIndex = movies.firstIndex(where: { $0.id == indexedSong.movie.id }) {
            currentMovieIndex = movieIndex
            preSelectedSong = indexedSong.song
            print("🎬 Navigating to movie: \(indexedSong.movie.title) at index: \(movieIndex)")
            print("🎵 Pre-selecting song: \(indexedSong.song.title)")
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

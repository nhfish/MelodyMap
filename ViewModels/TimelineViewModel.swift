import Foundation

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var songs: [Song] = []
    @Published var selectedSong: Song?
    @Published var currentMovieIndex: Int = 0 {
        didSet {
            print("🎬 TimelineViewModel currentMovieIndex changed to: \(currentMovieIndex)")
        }
    }
    @Published var preSelectedSong: Song? {
        didSet {
            if let song = preSelectedSong {
                print("🎵 TimelineViewModel preSelectedSong set to: \(song.title)")
            } else {
                print("🎵 TimelineViewModel preSelectedSong cleared")
            }
        }
    }
    
    init() {
        // No-op: movies and songs are set by AppState
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
            print("❌ TimelineViewModel: No remaining uses, triggering watch ad reward")
            // Directly trigger watch ad instead of showing quota sheet
            watchAd()
        } else {
            // Consume the view and present song detail
            UsageTrackerService.shared.consumeView()
            // The view will handle presenting the song detail
        }
    }
    
    // MARK: - Phase 7-3 Stub
    func watchAd() {
        UsageTrackerService.shared.addRewarded(2)
        
        // If user was trying to view a song when they had no remaining uses,
        // the song detail should already be set in selectedSong, so no additional action needed
        // The view will handle presenting the song detail
        print("✅ TimelineViewModel: Ad watched, song detail should be presented")
    }
}

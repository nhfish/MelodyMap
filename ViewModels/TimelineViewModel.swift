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
    @Published var showQuotaSheet: Bool = false
    
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
        if !UsageTrackerService.shared.canConsume() {
            print("❌ TimelineViewModel: No remaining uses, showing quota sheet")
            showQuotaSheet = true
            return
        }
        // Consume the view and present song detail
        UsageTrackerService.shared.consumeView()
        selectedSong = song
    }
    
    // Called from QuotaExceededSheet action
    func handleWatchAd() {
        UsageTrackerService.shared.addRewarded(2)
        showQuotaSheet = false
    }
    func handleUpgrade() {
        // This would trigger the paywall in the app state
        showQuotaSheet = false
    }
}

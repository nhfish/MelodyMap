import Foundation

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var songs: [Song] = []
    @Published var showingQuotaSheet = false
    @Published var selectedSong: Song?

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

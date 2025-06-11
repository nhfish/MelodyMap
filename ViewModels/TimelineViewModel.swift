import Foundation

final class TimelineViewModel: ObservableObject {
    @Published var movies: [Movie] = []

    func load() {
        // Placeholder loading logic
        movies = []
    }
}

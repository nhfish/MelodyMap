import Foundation

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Song] = []

    func search() {
        // Placeholder search logic
        results = []
    }
}

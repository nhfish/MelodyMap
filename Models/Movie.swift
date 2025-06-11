import Foundation

struct Movie: Identifiable {
    let id = UUID()
    var title: String
    var releaseYear: Int
    var runtime: TimeInterval
    var songs: [Song]
}

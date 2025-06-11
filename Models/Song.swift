import Foundation

struct Song: Identifiable {
    let id = UUID()
    var movieTitle: String
    var title: String
    var singers: [String]
    var startTime: TimeInterval
    var releaseYear: Int
    var runtime: TimeInterval
    var streamingLinks: [URL]
    var purchaseLinks: [URL]
    var keywords: [String]
    var blurb: String
}

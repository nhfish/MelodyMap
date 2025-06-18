import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id: String
    let movieId: String
    let title: String
    let percent: Int?
    let startTime: String?
    let singers: [String]
    let releaseYear: Int
    let movieRuntimeMinutes: Int
    let streamingLinks: [String]
    let purchaseLinks: [String]
    let keywords: [String]
    let blurb: String?
}

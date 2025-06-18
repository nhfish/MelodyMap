import Foundation

struct Movie: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let imageURL: String
    let releaseYear: Int
    let sortOrder: Int
}

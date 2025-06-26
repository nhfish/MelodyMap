import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id: String
    let movieId: String
    let title: String
    let percent: Double?
    let startTime: String?
    let singers: [String]
    let releaseYear: Int
    let movieRuntimeMinutes: Int
    let streamingLinks: [String]
    let purchaseLinks: [String]
    let keywords: [String]
    let blurb: String?

    enum CodingKeys: String, CodingKey {
        case id, movieId, title, percent, startTime, singers, releaseYear, movieRuntimeMinutes, streamingLinks, purchaseLinks, keywords, blurb
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        movieId = try container.decode(String.self, forKey: .movieId)
        title = try container.decode(String.self, forKey: .title)
        startTime = try container.decodeIfPresent(String.self, forKey: .startTime)
        singers = try container.decode([String].self, forKey: .singers)
        releaseYear = try container.decode(Int.self, forKey: .releaseYear)
        movieRuntimeMinutes = try container.decode(Int.self, forKey: .movieRuntimeMinutes)
        streamingLinks = try container.decode([String].self, forKey: .streamingLinks)
        purchaseLinks = try container.decode([String].self, forKey: .purchaseLinks)
        keywords = try container.decode([String].self, forKey: .keywords)
        blurb = try container.decodeIfPresent(String.self, forKey: .blurb)
        // Robust percent decoding
        print("🔍 Decoding percent for song '\(title)'")
        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .percent) {
            print("🔍 Found Double percent: \(doubleValue)")
            percent = doubleValue
        } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: .percent) {
            print("🔍 Found Int percent: \(intValue), converting to Double: \(Double(intValue))")
            percent = Double(intValue)
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .percent) {
            print("🔍 Found String percent: '\(stringValue)', converting to Double: \(Double(stringValue) ?? 0.0)")
            percent = Double(stringValue)
        } else {
            print("🔍 No percent value found, setting to nil")
            percent = nil
        }
    }

    // Default memberwise init for tests and manual creation
    init(id: String, movieId: String, title: String, percent: Double?, startTime: String?, singers: [String], releaseYear: Int, movieRuntimeMinutes: Int, streamingLinks: [String], purchaseLinks: [String], keywords: [String], blurb: String?) {
        self.id = id
        self.movieId = movieId
        self.title = title
        self.percent = percent
        self.startTime = startTime
        self.singers = singers
        self.releaseYear = releaseYear
        self.movieRuntimeMinutes = movieRuntimeMinutes
        self.streamingLinks = streamingLinks
        self.purchaseLinks = purchaseLinks
        self.keywords = keywords
        self.blurb = blurb
    }

    /// Computed property that calculates the percentage based on startTime and movieRuntimeMinutes
    var calculatedPercent: Double {
        guard let startTime = startTime, !startTime.isEmpty else { return 0.0 }
        
        // Parse startTime (HH:MM:SS format)
        let timeParts = startTime.split(separator: ":").map { String($0) }
        guard timeParts.count >= 2 else { return 0.0 }
        
        // Convert to seconds
        let hours = Int(timeParts[0]) ?? 0
        let minutes = Int(timeParts[1]) ?? 0
        let seconds = timeParts.count > 2 ? (Int(timeParts[2].split(separator: ".").first ?? "0") ?? 0) : 0
        
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        let movieRuntimeSeconds = movieRuntimeMinutes * 60
        
        guard movieRuntimeSeconds > 0 else { return 0.0 }
        
        let calculatedPercent = Double(totalSeconds) / Double(movieRuntimeSeconds) * 100.0
        print("🔢 Calculated percent for '\(title)': startTime=\(startTime) (\(totalSeconds)s) / runtime=\(movieRuntimeMinutes)m (\(movieRuntimeSeconds)s) = \(calculatedPercent)%")
        
        return calculatedPercent
    }
    
    /// Returns the percent from server if valid, otherwise calculates it
    var effectivePercent: Double {
        if let serverPercent = percent, serverPercent > 0 {
            return serverPercent
        } else {
            return calculatedPercent
        }
    }
}

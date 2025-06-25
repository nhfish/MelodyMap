import Foundation
@testable import MelodyMap

// MARK: - Mock Data for Testing

struct MockData {
    
    // MARK: - Sample Movies
    
    static let sampleMovies: [Movie] = [
        Movie(id: "frozen", title: "Frozen", imageURL: "https://example.com/frozen.jpg", releaseYear: 2013, sortOrder: 1),
        Movie(id: "moana", title: "Moana", imageURL: "https://example.com/moana.jpg", releaseYear: 2016, sortOrder: 2),
        Movie(id: "lionking", title: "The Lion King", imageURL: "https://example.com/lionking.jpg", releaseYear: 1994, sortOrder: 3),
        Movie(id: "toystory", title: "Toy Story", imageURL: "https://example.com/toystory.jpg", releaseYear: 1995, sortOrder: 4),
        Movie(id: "aladdin", title: "Aladdin", imageURL: "https://example.com/aladdin.jpg", releaseYear: 1992, sortOrder: 5)
    ]
    
    // MARK: - Sample Songs
    
    static let sampleSongs: [Song] = [
        // Frozen Songs
        Song(
            id: "let-it-go",
            movieId: "frozen",
            title: "Let It Go",
            percent: 50,
            startTime: "01:30:00",
            singers: ["Elsa", "Idina Menzel"],
            releaseYear: 2013,
            movieRuntimeMinutes: 102,
            streamingLinks: ["https://disneyplus.com/frozen"],
            purchaseLinks: ["https://itunes.apple.com/let-it-go"],
            keywords: ["snow", "ice", "winter", "magic", "freedom"],
            blurb: "Elsa's signature song about embracing her powers and finding freedom."
        ),
        Song(
            id: "do-you-want-to-build-a-snowman",
            movieId: "frozen",
            title: "Do You Want to Build a Snowman?",
            percent: 15,
            startTime: "00:15:00",
            singers: ["Anna", "Kristen Bell"],
            releaseYear: 2013,
            movieRuntimeMinutes: 102,
            streamingLinks: ["https://disneyplus.com/frozen"],
            purchaseLinks: ["https://itunes.apple.com/snowman"],
            keywords: ["snowman", "sisters", "childhood", "friendship"],
            blurb: "Anna's plea to her sister Elsa to play together."
        ),
        
        // Moana Songs
        Song(
            id: "how-far-ill-go",
            movieId: "moana",
            title: "How Far I'll Go",
            percent: 30,
            startTime: "00:45:00",
            singers: ["Moana", "Auli'i Cravalho"],
            releaseYear: 2016,
            movieRuntimeMinutes: 107,
            streamingLinks: ["https://disneyplus.com/moana"],
            purchaseLinks: ["https://itunes.apple.com/how-far-ill-go"],
            keywords: ["ocean", "journey", "adventure", "destiny", "island"],
            blurb: "Moana's song about her desire to explore beyond her island."
        ),
        Song(
            id: "youre-welcome",
            movieId: "moana",
            title: "You're Welcome",
            percent: 60,
            startTime: "01:15:00",
            singers: ["Maui", "Dwayne Johnson"],
            releaseYear: 2016,
            movieRuntimeMinutes: 107,
            streamingLinks: ["https://disneyplus.com/moana"],
            purchaseLinks: ["https://itunes.apple.com/youre-welcome"],
            keywords: ["maui", "demigod", "boastful", "funny", "hero"],
            blurb: "Maui's boastful song about his legendary deeds."
        ),
        
        // Lion King Songs
        Song(
            id: "hakuna-matata",
            movieId: "lionking",
            title: "Hakuna Matata",
            percent: 40,
            startTime: "00:50:00",
            singers: ["Timon", "Pumbaa", "Young Simba"],
            releaseYear: 1994,
            movieRuntimeMinutes: 88,
            streamingLinks: ["https://disneyplus.com/lionking"],
            purchaseLinks: ["https://itunes.apple.com/hakuna-matata"],
            keywords: ["worry-free", "philosophy", "friendship", "fun"],
            blurb: "Timon and Pumbaa's carefree philosophy song."
        ),
        Song(
            id: "circle-of-life",
            movieId: "lionking",
            title: "Circle of Life",
            percent: 5,
            startTime: "00:05:00",
            singers: ["Rafiki", "Chorus"],
            releaseYear: 1994,
            movieRuntimeMinutes: 88,
            streamingLinks: ["https://disneyplus.com/lionking"],
            purchaseLinks: ["https://itunes.apple.com/circle-of-life"],
            keywords: ["birth", "ceremony", "africa", "epic", "opening"],
            blurb: "The epic opening song celebrating Simba's birth."
        ),
        
        // Toy Story Songs
        Song(
            id: "youve-got-a-friend-in-me",
            movieId: "toystory",
            title: "You've Got a Friend in Me",
            percent: 10,
            startTime: "00:10:00",
            singers: ["Randy Newman"],
            releaseYear: 1995,
            movieRuntimeMinutes: 81,
            streamingLinks: ["https://disneyplus.com/toystory"],
            purchaseLinks: ["https://itunes.apple.com/friend-in-me"],
            keywords: ["friendship", "toys", "loyalty", "classic"],
            blurb: "The iconic theme song about friendship between toys."
        ),
        
        // Aladdin Songs
        Song(
            id: "a-whole-new-world",
            movieId: "aladdin",
            title: "A Whole New World",
            percent: 70,
            startTime: "01:20:00",
            singers: ["Aladdin", "Jasmine", "Brad Kane", "Lea Salonga"],
            releaseYear: 1992,
            movieRuntimeMinutes: 90,
            streamingLinks: ["https://disneyplus.com/aladdin"],
            purchaseLinks: ["https://itunes.apple.com/whole-new-world"],
            keywords: ["magic carpet", "romance", "adventure", "flying"],
            blurb: "Aladdin and Jasmine's romantic magic carpet ride song."
        )
    ]
    
    // MARK: - Sample Indexed Songs
    
    static var sampleIndexedSongs: [IndexedSong] {
        let movieDict = Dictionary(uniqueKeysWithValues: sampleMovies.map { ($0.id, $0) })
        return sampleSongs.compactMap { song -> IndexedSong? in
            guard let movie = movieDict[song.movieId] else { return nil }
            return IndexedSong(song: song, movie: movie)
        }
    }
    
    // MARK: - Sample User Profiles
    
    static let sampleUserProfile = UserProfile(
        id: "test-user-1",
        name: "Test User",
        email: "test@example.com",
        subscriptionStatus: .free,
        joinDate: Date(),
        lastActive: Date()
    )
    
    static let samplePremiumUserProfile = UserProfile(
        id: "test-user-2",
        name: "Premium User",
        email: "premium@example.com",
        subscriptionStatus: .premium,
        joinDate: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 30 days ago
        lastActive: Date()
    )
    
    // MARK: - Sample Search Queries
    
    static let sampleSearchQueries = [
        "Let It Go",
        "Frozen",
        "snow",
        "ice",
        "ocean",
        "adventure",
        "friendship",
        "magic",
        "winter",
        "journey"
    ]
    
    // MARK: - Sample Error Scenarios
    
    static let sampleNetworkError = NSError(
        domain: "com.melodymap.network",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "Internal server error"]
    )
    
    static let sampleTimeoutError = NSError(
        domain: "com.melodymap.network",
        code: -1001,
        userInfo: [NSLocalizedDescriptionKey: "Request timed out"]
    )
    
    // MARK: - Sample Usage Data
    
    static let sampleUsageData: [String: Any] = [
        "UsageTrackerService.lastDate": Date(),
        "UsageTrackerService.remaining": 2,
        "UsageTrackerService.unlockedSongs": [
            "let-it-go": Date().addingTimeInterval(5 * 60), // 5 minutes ago
            "how-far-ill-go": Date().addingTimeInterval(10 * 60) // 10 minutes ago
        ]
    ]
    
    // MARK: - Sample Favorites
    
    static let sampleFavoritedSongIDs = [
        "let-it-go",
        "how-far-ill-go",
        "hakuna-matata"
    ]
    
    // MARK: - Helper Methods
    
    static func createMockSong(id: String, title: String, movieId: String) -> Song {
        return Song(
            id: id,
            movieId: movieId,
            title: title,
            percent: 50,
            startTime: "01:00:00",
            singers: ["Test Singer"],
            releaseYear: 2020,
            movieRuntimeMinutes: 120,
            streamingLinks: [],
            purchaseLinks: [],
            keywords: ["test"],
            blurb: "Test song for unit testing"
        )
    }
    
    static func createMockMovie(id: String, title: String) -> Movie {
        return Movie(
            id: id,
            title: title,
            imageURL: "https://example.com/\(id).jpg",
            releaseYear: 2020,
            sortOrder: 1
        )
    }
    
    static func createMockIndexedSong(songId: String, songTitle: String, movieId: String, movieTitle: String) -> IndexedSong {
        let song = createMockSong(id: songId, title: songTitle, movieId: movieId)
        let movie = createMockMovie(id: movieId, title: movieTitle)
        return IndexedSong(song: song, movie: movie)
    }
    
    // MARK: - Performance Test Data
    
    static let largeSongDataset: [Song] = {
        return (1...1000).map { i in
            Song(
                id: "song-\(i)",
                movieId: "movie-\(i % 10 + 1)",
                title: "Test Song \(i)",
                percent: i % 100,
                startTime: String(format: "%02d:%02d:00", i / 60, i % 60),
                singers: ["Singer \(i)"],
                releaseYear: 2020,
                movieRuntimeMinutes: 120,
                streamingLinks: [],
                purchaseLinks: [],
                keywords: ["test", "song", "\(i)"],
                blurb: "Test song \(i) for performance testing"
            )
        }
    }()
    
    static let largeMovieDataset: [Movie] = {
        return (1...100).map { i in
            Movie(
                id: "movie-\(i)",
                title: "Test Movie \(i)",
                imageURL: "https://example.com/movie-\(i).jpg",
                releaseYear: 2020,
                sortOrder: i
            )
        }
    }()
} 
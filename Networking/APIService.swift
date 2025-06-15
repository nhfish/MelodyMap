//
//  APIService.swift
//  MelodyMap
//
//  Pulls JSON from the Apps-Script middleware and caches locally.
//
import Foundation

@MainActor
final class APIService: ObservableObject {

    // MARK: Singleton
    static let shared = APIService()
    private init() {}

    // MARK: Config
    private let baseURL  = "https://script.google.com/macros/s/AKfycbyyOmZP_2zt1k1PbyS_-AnoRnwp25yBceLZwPe6hRLduZpULYZ7e_Lcxnf8pSKiPL9a/exec"
    private let apiToken = "mM25tOk1206"

    // Location of cached files
    private var songsCacheURL : URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("melodymap_songs.json")
    }
    private var moviesCacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("melodymap_movies.json")
    }

    // MARK: Public API
    func fetchSongs() async throws -> [Song] {
        try await request(mode: "songs", cacheURL: songsCacheURL)
    }

    func fetchMovies() async throws -> [Movie] {
        try await request(mode: "movies", cacheURL: moviesCacheURL)
    }

    // MARK: Internal request helper
    private func request<T: Decodable>(mode: String, cacheURL: URL) async throws -> [T] {

        // Build URL with query params
        var comps = URLComponents(string: baseURL)!
        comps.queryItems = [
            .init(name: "token", value: apiToken),
            .init(name: "mode",  value: mode)
        ]

        // Try network call first
        do {
            let (data, _) = try await URLSession.shared.data(from: comps.url!)
            // Save raw JSON to cache for offline use
            try? data.write(to: cacheURL, options: .atomic)
            return try JSONDecoder().decode([T].self, from: data)

        } catch {
            // Fallback to cached file
            let cachedData = try Data(contentsOf: cacheURL)
            return try JSONDecoder().decode([T].self, from: cachedData)
        }
    }
}

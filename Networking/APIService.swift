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
        let context = "APIService.\(mode)"
        
        // Build URL with query params
        var comps = URLComponents(string: baseURL)!
        comps.queryItems = [
            .init(name: "token", value: apiToken),
            .init(name: "mode",  value: mode)
        ]

        // Create URLSession configuration that follows redirects
        let config = URLSessionConfiguration.default
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: config)

        // Try network call first
        do {
            print("🌐 Fetching \(mode) from API...")
            let (data, response) = try await session.data(from: comps.url!)
            
            // Check if we got a successful response
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    // Save raw JSON to cache for offline use
                    do {
                        try data.write(to: cacheURL, options: .atomic)
                        print("💾 Cached \(mode) data")
                    } catch {
                        ErrorHandlingService.shared.handle(
                            MelodyMapError.cacheError(underlying: error),
                            context: context
                        )
                    }
                    
                    do {
                        let decoded = try JSONDecoder().decode([T].self, from: data)
                        print("✅ Successfully decoded \(decoded.count) \(mode)")
                        return decoded
                    } catch {
                        let decodingError = MelodyMapError.decodingError(underlying: error)
                        ErrorHandlingService.shared.handle(decodingError, context: context)
                        throw decodingError
                    }
                } else {
                    let serverError = MelodyMapError.serverError(statusCode: httpResponse.statusCode)
                    ErrorHandlingService.shared.handle(serverError, context: context)
                    throw serverError
                }
            }
            
            let unknownError = MelodyMapError.unknownError(underlying: URLError(.badServerResponse))
            ErrorHandlingService.shared.handle(unknownError, context: context)
            throw unknownError

        } catch {
            // Check if it's already a MelodyMapError
            if let melodyMapError = error as? MelodyMapError {
                ErrorHandlingService.shared.handle(melodyMapError, context: context)
            } else {
                let networkError = MelodyMapError.networkError(underlying: error)
                ErrorHandlingService.shared.handle(networkError, context: context)
            }
            
            print("⚠️ Network request failed for \(mode): \(error)")
            print("🔄 Falling back to cached data...")
            
            // Fallback to cached file
            do {
                let cachedData = try Data(contentsOf: cacheURL)
                let decoded = try JSONDecoder().decode([T].self, from: cachedData)
                print("✅ Loaded \(decoded.count) \(mode) from cache")
                return decoded
            } catch {
                let cacheError = MelodyMapError.cacheError(underlying: error)
                ErrorHandlingService.shared.handle(cacheError, context: context)
                print("❌ Cache fallback failed: \(error)")
                throw cacheError
            }
        }
    }
    
    // MARK: - Retry Logic
    
    func fetchSongsWithRetry(maxRetries: Int = 3) async throws -> [Song] {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await fetchSongs()
            } catch {
                lastError = error
                
                if let melodyMapError = error as? MelodyMapError,
                   !melodyMapError.isRetryable {
                    throw error
                }
                
                if attempt < maxRetries {
                    print("🔄 Retry attempt \(attempt + 1) for songs...")
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000) // Exponential backoff
                }
            }
        }
        
        throw lastError ?? MelodyMapError.unknownError(underlying: URLError(.unknown))
    }
    
    func fetchMoviesWithRetry(maxRetries: Int = 3) async throws -> [Movie] {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await fetchMovies()
            } catch {
                lastError = error
                
                if let melodyMapError = error as? MelodyMapError,
                   !melodyMapError.isRetryable {
                    throw error
                }
                
                if attempt < maxRetries {
                    print("🔄 Retry attempt \(attempt + 1) for movies...")
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000) // Exponential backoff
                }
            }
        }
        
        throw lastError ?? MelodyMapError.unknownError(underlying: URLError(.unknown))
    }
}

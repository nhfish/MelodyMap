//
//  APIService.swift
//  SwiftUI-Basic-Combine

import Foundation
import Combine

protocol APIRequestType {
    associatedtype Response: Decodable
    
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

protocol APIServiceType {
    func response<Request>(from request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request: APIRequestType
}

final class APIService: APIServiceType {
    private let baseURL: URL
    
    init(baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!) {
        self.baseURL = baseURL
    }
    
    func response<Request>(from request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request : APIRequestType {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = request.queryItems
        urlComponents.path = request.path
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, urlResponse in data }
            .mapError { _ in APIServiceError.responseError }
            .decode(type: Request.Response.self, decoder: decoder)
            .mapError(APIServiceError.parseError)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

 

import Foundation

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case requestFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid"
        case .noData:
            return "No data received from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Data Fetcher Protocol
/// Protocol for fetching investment data - enables dependency injection
protocol DataFetcher {
    func fetchAssets() async throws -> [StockAsset]
}

// MARK: - Network Service
/// Async/await based network service for API calls
final class NetworkService {
    
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    /// Generic async fetch method
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        do {
            let (data, _) = try await urlSession.data(from: url)
            return try jsonDecoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingFailed(decodingError)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}

// MARK: - Live Data Fetcher
/// Production implementation that fetches from real API
final class LiveDataFetcher: DataFetcher {
    
    private let networkService: NetworkService
    private let apiEndpoint: URL
    
    init(
        networkService: NetworkService = NetworkService(),
        apiEndpoint: URL = URL(string: "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/")!
    ) {
        self.networkService = networkService
        self.apiEndpoint = apiEndpoint
    }
    
    func fetchAssets() async throws -> [StockAsset] {
        let response: InvestmentAPIResponse = try await networkService.fetch(from: apiEndpoint)
        return response.payload?.assets ?? []
    }
}

// MARK: - Mock Data Fetcher
/// Test implementation with predefined data
final class MockDataFetcher: DataFetcher {
    
    private let mockAssets: [StockAsset]
    private let simulatedDelay: TimeInterval
    private let shouldFail: Bool
    
    init(
        assets: [StockAsset],
        delay: TimeInterval = 0,
        shouldFail: Bool = false
    ) {
        self.mockAssets = assets
        self.simulatedDelay = delay
        self.shouldFail = shouldFail
    }
    
    func fetchAssets() async throws -> [StockAsset] {
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        
        if shouldFail {
            throw NetworkError.noData
        }
        
        return mockAssets
    }
}

//
//  NetworkServiceTests.swift
//  PortfolioDemoAppTests
//
//  Created by Anand Amar on 30/12/25.
//

import XCTest
@testable import PortfolioDemoApp

final class NetworkServiceTests: XCTestCase {
    
    // MARK: - NetworkService Initialization Tests
    
    func testNetworkServiceInitialization() {
        // Given/When
        let networkService = NetworkService()
        
        // Then
        XCTAssertNotNil(networkService)
    }
    
    func testNetworkServiceWithCustomSession() {
        // Given
        let customSession = URLSession.shared
        
        // When
        let networkService = NetworkService(urlSession: customSession)
        
        // Then
        XCTAssertNotNil(networkService)
    }
    
    // MARK: - NetworkError Tests
    
    func testNetworkErrorDescriptions() {
        // Given/When/Then
        let invalidURLError = NetworkError.invalidURL
        XCTAssertNotNil(invalidURLError.errorDescription)
        
        let noDataError = NetworkError.noData
        XCTAssertNotNil(noDataError.errorDescription)
        
        let decodingError = NetworkError.decodingFailed(NSError(domain: "Test", code: 1))
        XCTAssertNotNil(decodingError.errorDescription)
        
        let requestError = NetworkError.requestFailed(NSError(domain: "Test", code: 1))
        XCTAssertNotNil(requestError.errorDescription)
    }
    
    // MARK: - Live Data Fetcher Tests
    
    func testLiveDataFetcherInitialization() {
        // Given/When
        let fetcher = LiveDataFetcher()
        
        // Then
        XCTAssertNotNil(fetcher)
    }
    
    func testLiveDataFetcherWithCustomEndpoint() {
        // Given
        let customURL = URL(string: "https://custom-endpoint.com")!
        
        // When
        let fetcher = LiveDataFetcher(apiEndpoint: customURL)
        
        // Then
        XCTAssertNotNil(fetcher)
    }
    
    func testLiveDataFetcherWithCustomNetworkService() {
        // Given
        let networkService = NetworkService()
        
        // When
        let fetcher = LiveDataFetcher(networkService: networkService)
        
        // Then
        XCTAssertNotNil(fetcher)
    }
    
    // MARK: - Mock Data Fetcher Tests
    
    func testMockDataFetcherSuccess() async throws {
        // Given
        let mockAssets = [
            StockAsset(
                tickerSymbol: "TEST",
                shareCount: 1,
                lastTradedPrice: 100.0,
                averageBuyPrice: 100.0,
                previousClosePrice: 100.0
            )
        ]
        let fetcher = MockDataFetcher(assets: mockAssets)
        
        // When
        let assets = try await fetcher.fetchAssets()
        
        // Then
        XCTAssertEqual(assets.count, 1)
        XCTAssertEqual(assets.first?.tickerSymbol, "TEST")
    }
    
    func testMockDataFetcherWithMultipleAssets() async throws {
        // Given
        let mockAssets = [
            StockAsset(
                tickerSymbol: "TEST1",
                shareCount: 1,
                lastTradedPrice: 100.0,
                averageBuyPrice: 100.0,
                previousClosePrice: 100.0
            ),
            StockAsset(
                tickerSymbol: "TEST2",
                shareCount: 2,
                lastTradedPrice: 200.0,
                averageBuyPrice: 200.0,
                previousClosePrice: 200.0
            )
        ]
        let fetcher = MockDataFetcher(assets: mockAssets)
        
        // When
        let assets = try await fetcher.fetchAssets()
        
        // Then
        XCTAssertEqual(assets.count, 2)
        XCTAssertEqual(assets[0].tickerSymbol, "TEST1")
        XCTAssertEqual(assets[1].tickerSymbol, "TEST2")
    }
    
    func testMockDataFetcherWithDelay() async throws {
        // Given
        let mockAssets: [StockAsset] = []
        let fetcher = MockDataFetcher(assets: mockAssets, delay: 0.1)
        let startTime = Date()
        
        // When
        let _ = try await fetcher.fetchAssets()
        
        // Then
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsed, 0.05, "Should have at least some delay")
        XCTAssertLessThanOrEqual(elapsed, 0.2, "Should complete within reasonable time")
    }
    
    func testMockDataFetcherWithNoDelay() async throws {
        // Given
        let mockAssets = [
            StockAsset(
                tickerSymbol: "TEST",
                shareCount: 1,
                lastTradedPrice: 100.0,
                averageBuyPrice: 100.0,
                previousClosePrice: 100.0
            )
        ]
        let fetcher = MockDataFetcher(assets: mockAssets, delay: 0)
        let startTime = Date()
        
        // When
        let _ = try await fetcher.fetchAssets()
        
        // Then
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertTrue(elapsed < 0.1, "Should complete quickly without delay") // Should be very fast
    }
    
    func testMockDataFetcherFailure() async {
        // Given
        let fetcher = MockDataFetcher(assets: [], shouldFail: true)
        
        // When/Then
        do {
            let _ = try await fetcher.fetchAssets()
            XCTFail("Expected failure")
        } catch {
            if case NetworkError.noData = error {
                // Expected
            } else {
                XCTFail("Expected noData error, got: \(error)")
            }
        }
    }
    
    func testMockDataFetcherWithEmptyAssets() async throws {
        // Given
        let fetcher = MockDataFetcher(assets: [])
        
        // When
        let assets = try await fetcher.fetchAssets()
        
        // Then
        XCTAssertEqual(assets.count, 0)
    }
    
    // MARK: - DataFetcher Protocol Tests
    
    func testDataFetcherProtocolConformance() {
        // Given
        let mockFetcher = MockDataFetcher(assets: [])
        let liveFetcher = LiveDataFetcher()
        
        // Then
        XCTAssertTrue(mockFetcher is DataFetcher)
        XCTAssertTrue(liveFetcher is DataFetcher)
    }
}


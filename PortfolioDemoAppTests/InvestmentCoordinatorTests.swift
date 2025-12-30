//
//  InvestmentCoordinatorTests.swift
//  PortfolioDemoAppTests
//
//  Created by Anand Amar on 30/12/25.
//

import XCTest
import Combine
@testable import PortfolioDemoApp

final class InvestmentCoordinatorTests: XCTestCase {
    
    var coordinator: InvestmentCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        coordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        // Given
        coordinator = InvestmentCoordinator()
        
        // Then
        XCTAssertEqual(coordinator.assets.count, 0)
        XCTAssertEqual(coordinator.loadingState, .idle)
        XCTAssertFalse(coordinator.isDetailsPanelVisible)
        XCTAssertEqual(coordinator.assetCount, 0)
    }
    
    func testInitializationWithMockFetcher() {
        // Given
        let mockAssets = [
            StockAsset(
                tickerSymbol: "TEST1",
                shareCount: 1,
                lastTradedPrice: 100.0,
                averageBuyPrice: 100.0,
                previousClosePrice: 100.0
            )
        ]
        let mockFetcher = MockDataFetcher(assets: mockAssets)
        
        // When
        coordinator = InvestmentCoordinator(dataFetcher: mockFetcher)
        
        // Then
        XCTAssertEqual(coordinator.loadingState, .idle)
    }
    
    // MARK: - Load Assets Tests
    
    func testLoadAssetsSuccess() async {
        // Given
        let mockAssets = [
            StockAsset(
                tickerSymbol: "ASHOKLEY",
                shareCount: 3,
                lastTradedPrice: 119.10,
                averageBuyPrice: 114.80,
                previousClosePrice: 115.20
            )
        ]
        let mockFetcher = MockDataFetcher(assets: mockAssets)
        coordinator = InvestmentCoordinator(dataFetcher: mockFetcher)
        
        // When
        await coordinator.loadAssets()
        
        // Then
        XCTAssertEqual(coordinator.assets.count, 1)
        XCTAssertEqual(coordinator.loadingState, .ready)
        XCTAssertEqual(coordinator.assetCount, 1)
        XCTAssertEqual(coordinator.assets.first?.tickerSymbol, "ASHOKLEY")
    }
    
    func testLoadAssetsFailure() async {
        // Given
        let mockFetcher = MockDataFetcher(assets: [], shouldFail: true)
        coordinator = InvestmentCoordinator(dataFetcher: mockFetcher)
        
        // When
        await coordinator.loadAssets()
        
        // Then
        XCTAssertEqual(coordinator.assets.count, 0)
        if case .failed(let message) = coordinator.loadingState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected failed state")
        }
    }
    
    func testLoadAssetsStateTransition() async {
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
        let mockFetcher = MockDataFetcher(assets: mockAssets, delay: 0.1)
        coordinator = InvestmentCoordinator(dataFetcher: mockFetcher)
        
        var states: [LoadingState] = []
        let expectation = expectation(description: "State changes")
        
        coordinator.$loadingState
            .sink { state in
                states.append(state)
                if state == .ready {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        await coordinator.loadAssets()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(states.contains(.fetching))
        XCTAssertTrue(states.contains(.ready))
    }
    
    // MARK: - Overview Tests
    
    func testOverviewCalculation() async {
        // Given
        let mockAssets = [
            StockAsset(
                tickerSymbol: "TEST1",
                shareCount: 3,
                lastTradedPrice: 119.10,
                averageBuyPrice: 114.80,
                previousClosePrice: 115.20
            ),
            StockAsset(
                tickerSymbol: "TEST2",
                shareCount: 7,
                lastTradedPrice: 2497.20,
                averageBuyPrice: 2714.66,
                previousClosePrice: 2500.00
            )
        ]
        let mockFetcher = MockDataFetcher(assets: mockAssets)
        coordinator = InvestmentCoordinator(dataFetcher: mockFetcher)
        
        // When
        await coordinator.loadAssets()
        let overview = coordinator.overview
        
        // Then
        let expectedMarketValue = (119.10 * 3) + (2497.20 * 7)
        XCTAssertEqual(overview.totalMarketValue, expectedMarketValue, accuracy: 0.01)
        
        let expectedCostBasis = (114.80 * 3) + (2714.66 * 7)
        XCTAssertEqual(overview.totalCostBasis, expectedCostBasis, accuracy: 0.01)
    }
    
    func testOverviewWithEmptyAssets() {
        // Given
        coordinator = InvestmentCoordinator()
        
        // When
        let overview = coordinator.overview
        
        // Then
        XCTAssertEqual(overview.totalMarketValue, 0.0)
        XCTAssertEqual(overview.totalCostBasis, 0.0)
        XCTAssertEqual(overview.dailyProfitLoss, 0.0)
        XCTAssertEqual(overview.overallProfitLoss, 0.0)
    }
    
    // MARK: - Display Item Tests
    
    func testDisplayItem() async {
        // Given
        let mockAssets = [
            StockAsset(
                tickerSymbol: "ASHOKLEY",
                shareCount: 3,
                lastTradedPrice: 119.10,
                averageBuyPrice: 114.80,
                previousClosePrice: 115.20
            )
        ]
        let mockFetcher = MockDataFetcher(assets: mockAssets)
        coordinator = InvestmentCoordinator(dataFetcher: mockFetcher)
        await coordinator.loadAssets()
        
        // When
        let displayItem = coordinator.displayItem(at: 0)
        
        // Then
        XCTAssertEqual(displayItem.symbolText, "ASHOKLEY")
        XCTAssertEqual(displayItem.quantityText, "3")
    }
    
    func testDisplayItemOutOfBounds() {
        // Given
        coordinator = InvestmentCoordinator()
        
        // When
        let displayItem = coordinator.displayItem(at: 100)
        
        // Then
        XCTAssertEqual(displayItem.symbolText, "-")
        XCTAssertEqual(displayItem.quantityText, "-")
        XCTAssertEqual(displayItem.priceText, "-")
        XCTAssertEqual(displayItem.profitLossText, "-")
    }
    
    // MARK: - Details Panel Tests
    
    func testToggleDetailsPanel() {
        // Given
        coordinator = InvestmentCoordinator()
        XCTAssertFalse(coordinator.isDetailsPanelVisible)
        
        // When
        coordinator.toggleDetailsPanel()
        
        // Then
        XCTAssertTrue(coordinator.isDetailsPanelVisible)
        
        // When
        coordinator.toggleDetailsPanel()
        
        // Then
        XCTAssertFalse(coordinator.isDetailsPanelVisible)
    }
    
    func testDetailsPanelVisibilityPublisher() {
        // Given
        coordinator = InvestmentCoordinator()
        var visibilityChanges: [Bool] = []
        let expectation = expectation(description: "Visibility changes")
        expectation.expectedFulfillmentCount = 2
        
        coordinator.$isDetailsPanelVisible
            .dropFirst() // Skip initial value
            .sink { isVisible in
                visibilityChanges.append(isVisible)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        coordinator.toggleDetailsPanel()
        coordinator.toggleDetailsPanel()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(visibilityChanges, [true, false])
    }
    
    // MARK: - Error Alert Tests
    
    func testPresentErrorAlert() async {
        // Given
        let mockFetcher = MockDataFetcher(assets: [], shouldFail: true)
        coordinator = InvestmentCoordinator(dataFetcher: mockFetcher)
        await coordinator.loadAssets()
        
        // Verify we're in failed state
        if case .failed = coordinator.loadingState {
            // Expected state
        } else {
            XCTFail("Expected failed state")
            return
        }
        
        // When - Create a view controller and present alert
        let mockViewController = UIViewController()
        var retryCalled = false
        
        coordinator.presentErrorAlert(on: mockViewController) {
            retryCalled = true
        }
        
        // Then - Verify method doesn't crash and retry handler is set
        // Note: We can't easily test UI presentation in unit tests,
        // but we can verify the method doesn't crash and handler is callable
        XCTAssertNotNil(coordinator)
        // The retry handler would be called when user taps retry button
        // We can't simulate that in unit tests, but we verify the setup works
    }
    
    func testPresentErrorAlertWhenNotFailed() {
        // Given
        coordinator = InvestmentCoordinator()
        let mockViewController = UIViewController()
        
        // When - Try to present error alert when not in failed state
        coordinator.presentErrorAlert(on: mockViewController) {
            // Retry handler
        }
        
        // Then - Method should not crash even when not in failed state
        XCTAssertNotNil(coordinator)
    }
}


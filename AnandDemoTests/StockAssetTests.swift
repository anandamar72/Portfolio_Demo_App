//
//  StockAssetTests.swift
//  AnandDemoTests
//
//  Created by Anand Amar on 30/12/25.
//

import XCTest
@testable import AnandDemo

final class StockAssetTests: XCTestCase {
    
    // MARK: - Decoding Tests
    
    func testDecodeFromJSON() throws {
        // Given
        let json = """
        {
            "symbol": "ASHOKLEY",
            "quantity": 3,
            "ltp": 119.10,
            "avgPrice": 114.80,
            "close": 115.20
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let asset = try decoder.decode(StockAsset.self, from: json)
        
        // Then
        XCTAssertEqual(asset.tickerSymbol, "ASHOKLEY")
        XCTAssertEqual(asset.shareCount, 3)
        XCTAssertEqual(asset.lastTradedPrice, 119.10, accuracy: 0.01)
        XCTAssertEqual(asset.averageBuyPrice, 114.80, accuracy: 0.01)
        XCTAssertEqual(asset.previousClosePrice, 115.20, accuracy: 0.01)
    }
    
    func testDecodeWithMissingFields() {
        // Given
        let json = """
        {
            "symbol": "TEST"
        }
        """.data(using: .utf8)!
        
        // When/Then
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(StockAsset.self, from: json))
    }
    
    // MARK: - Computed Properties Tests
    
    func testProfitLossCalculation() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 3,
            lastTradedPrice: 119.10,
            averageBuyPrice: 114.80,
            previousClosePrice: 115.20
        )
        
        // When
        let profitLoss = asset.profitLoss
        
        // Then
        // P&L = (119.10 - 114.80) * 3 = 12.90
        XCTAssertEqual(profitLoss, 12.90, accuracy: 0.01)
    }
    
    func testProfitLossNegative() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 7,
            lastTradedPrice: 2497.20,
            averageBuyPrice: 2714.66,
            previousClosePrice: 2500.00
        )
        
        // When
        let profitLoss = asset.profitLoss
        
        // Then
        // P&L = (2497.20 - 2714.66) * 7 = -1521.22
        XCTAssertEqual(profitLoss, -1521.22, accuracy: 0.01)
    }
    
    func testIsProfitable() {
        // Given - Profitable asset
        let profitableAsset = StockAsset(
            tickerSymbol: "TEST1",
            shareCount: 1,
            lastTradedPrice: 110.0,
            averageBuyPrice: 100.0,
            previousClosePrice: 105.0
        )
        
        // Given - Loss asset
        let lossAsset = StockAsset(
            tickerSymbol: "TEST2",
            shareCount: 1,
            lastTradedPrice: 90.0,
            averageBuyPrice: 100.0,
            previousClosePrice: 95.0
        )
        
        // Then
        XCTAssertTrue(profitableAsset.isProfitable)
        XCTAssertFalse(lossAsset.isProfitable)
    }
    
    func testCurrentMarketValue() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 3,
            lastTradedPrice: 119.10,
            averageBuyPrice: 114.80,
            previousClosePrice: 115.20
        )
        
        // When
        let marketValue = asset.currentMarketValue
        
        // Then
        // Market value = 119.10 * 3 = 357.30
        XCTAssertEqual(marketValue, 357.30, accuracy: 0.01)
    }
    
    func testInvestedAmount() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 3,
            lastTradedPrice: 119.10,
            averageBuyPrice: 114.80,
            previousClosePrice: 115.20
        )
        
        // When
        let investedAmount = asset.investedAmount
        
        // Then
        // Invested amount = 114.80 * 3 = 344.40
        XCTAssertEqual(investedAmount, 344.40, accuracy: 0.01)
    }
    
    func testDailyChange() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 3,
            lastTradedPrice: 119.10,
            averageBuyPrice: 114.80,
            previousClosePrice: 115.20
        )
        
        // When
        let dailyChange = asset.dailyChange
        
        // Then
        // Daily change = (115.20 - 119.10) * 3 = -11.70
        XCTAssertEqual(dailyChange, -11.70, accuracy: 0.01)
    }
    
    func testDailyChangePositive() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 1,
            lastTradedPrice: 90.0,
            averageBuyPrice: 100.0,
            previousClosePrice: 100.0
        )
        
        // When
        let dailyChange = asset.dailyChange
        
        // Then
        // Daily change = (100.0 - 90.0) * 1 = 10.0
        XCTAssertEqual(dailyChange, 10.0, accuracy: 0.01)
    }
    
    // MARK: - Display Item Tests
    
    func testToDisplayItem() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "ASHOKLEY",
            shareCount: 3,
            lastTradedPrice: 119.10,
            averageBuyPrice: 114.80,
            previousClosePrice: 115.20
        )
        
        // When
        let displayItem = asset.toDisplayItem()
        
        // Then
        XCTAssertEqual(displayItem.symbolText, "ASHOKLEY")
        XCTAssertEqual(displayItem.quantityText, "3")
        XCTAssertEqual(displayItem.priceText, "₹ 119.1")
        XCTAssertEqual(displayItem.profitLossText, "₹ 12.90")
        XCTAssertEqual(displayItem.indicatorColor, .profitGreen)
    }
    
    func testToDisplayItemWithLoss() {
        // Given
        let asset = StockAsset(
            tickerSymbol: "HDFC",
            shareCount: 7,
            lastTradedPrice: 2497.20,
            averageBuyPrice: 2714.66,
            previousClosePrice: 2500.00
        )
        
        // When
        let displayItem = asset.toDisplayItem()
        
        // Then
        XCTAssertEqual(displayItem.symbolText, "HDFC")
        XCTAssertEqual(displayItem.quantityText, "7")
        XCTAssertEqual(displayItem.priceText, "₹ 2497.2")
        XCTAssertTrue(displayItem.profitLossText.contains("-₹"))
        XCTAssertEqual(displayItem.indicatorColor, .lossRed)
    }
    
    // MARK: - Identifiable Tests
    
    func testIdentifiableConformance() {
        // Given
        let asset1 = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 1,
            lastTradedPrice: 100.0,
            averageBuyPrice: 100.0,
            previousClosePrice: 100.0
        )
        
        let asset2 = StockAsset(
            tickerSymbol: "TEST",
            shareCount: 1,
            lastTradedPrice: 100.0,
            averageBuyPrice: 100.0,
            previousClosePrice: 100.0
        )
        
        // Then
        XCTAssertNotEqual(asset1.id, asset2.id)
    }
}


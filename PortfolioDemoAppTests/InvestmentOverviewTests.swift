//
//  InvestmentOverviewTests.swift
//  PortfolioDemoAppTests
//
//  Created by Anand Amar on 30/12/25.
//

import XCTest
@testable import PortfolioDemoApp

final class InvestmentOverviewTests: XCTestCase {
    
    // MARK: - Test Data
    
    func makeAsset(
        symbol: String = "TEST",
        quantity: Int = 1,
        ltp: Double = 100.0,
        avgPrice: Double = 100.0,
        close: Double = 100.0
    ) -> StockAsset {
        StockAsset(
            tickerSymbol: symbol,
            shareCount: quantity,
            lastTradedPrice: ltp,
            averageBuyPrice: avgPrice,
            previousClosePrice: close
        )
    }
    
    // MARK: - Aggregation Tests
    
    func testAggregateEmptyAssets() {
        // Given
        let assets: [StockAsset] = []
        
        // When
        let overview = InvestmentOverview.aggregate(from: assets)
        
        // Then
        XCTAssertEqual(overview.totalMarketValue, 0.0, accuracy: 0.01)
        XCTAssertEqual(overview.totalCostBasis, 0.0, accuracy: 0.01)
        XCTAssertEqual(overview.dailyProfitLoss, 0.0, accuracy: 0.01)
        XCTAssertEqual(overview.overallProfitLoss, 0.0, accuracy: 0.01)
    }
    
    func testAggregateSingleAsset() {
        // Given
        let asset = makeAsset(
            symbol: "ASHOKLEY",
            quantity: 3,
            ltp: 119.10,
            avgPrice: 114.80,
            close: 115.20
        )
        
        // When
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // Then
        // Current value = 119.10 * 3 = 357.30
        XCTAssertEqual(overview.totalMarketValue, 357.30, accuracy: 0.01)
        
        // Total investment = 114.80 * 3 = 344.40
        XCTAssertEqual(overview.totalCostBasis, 344.40, accuracy: 0.01)
        
        // Today's PNL = (115.20 - 119.10) * 3 = -11.70
        XCTAssertEqual(overview.dailyProfitLoss, -11.70, accuracy: 0.01)
        
        // Total PNL = 357.30 - 344.40 = 12.90
        XCTAssertEqual(overview.overallProfitLoss, 12.90, accuracy: 0.01)
    }
    
    func testAggregateMultipleAssets() {
        // Given - Based on PDF example
        let assets = [
            makeAsset(symbol: "ASHOKLEY", quantity: 3, ltp: 119.10, avgPrice: 114.80, close: 115.20),
            makeAsset(symbol: "HDFC", quantity: 7, ltp: 2497.20, avgPrice: 2714.66, close: 2500.00),
            makeAsset(symbol: "ICICIBANK", quantity: 1, ltp: 624.70, avgPrice: 489.10, close: 625.00),
            makeAsset(symbol: "IDEA", quantity: 3, ltp: 9.95, avgPrice: 9.11, close: 10.00)
        ]
        
        // When
        let overview = InvestmentOverview.aggregate(from: assets)
        
        // Then
        // Current value = (119.10*3) + (2497.20*7) + (624.70*1) + (9.95*3)
        // = 357.30 + 17480.40 + 624.70 + 29.85 = 18492.25
        let expectedMarketValue = (119.10 * 3) + (2497.20 * 7) + (624.70 * 1) + (9.95 * 3)
        XCTAssertEqual(overview.totalMarketValue, expectedMarketValue, accuracy: 0.01)
        
        // Total investment = (114.80*3) + (2714.66*7) + (489.10*1) + (9.11*3)
        // = 344.40 + 19002.62 + 489.10 + 27.33 = 19863.45
        let expectedCostBasis = (114.80 * 3) + (2714.66 * 7) + (489.10 * 1) + (9.11 * 3)
        XCTAssertEqual(overview.totalCostBasis, expectedCostBasis, accuracy: 0.01)
        
        // Today's PNL = sum of ((close - ltp) * quantity)
        let expectedDailyPL = (115.20 - 119.10) * 3 + (2500.00 - 2497.20) * 7 + (625.00 - 624.70) * 1 + (10.00 - 9.95) * 3
        XCTAssertEqual(overview.dailyProfitLoss, expectedDailyPL, accuracy: 0.01)
        
        // Total PNL = Market Value - Cost Basis
        let expectedTotalPL = expectedMarketValue - expectedCostBasis
        XCTAssertEqual(overview.overallProfitLoss, expectedTotalPL, accuracy: 0.01)
    }
    
    // MARK: - Computed Properties Tests
    
    func testProfitLossPercentage() {
        // Given
        let asset = makeAsset(quantity: 10, ltp: 110.0, avgPrice: 100.0)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let percentage = overview.profitLossPercentage
        
        // Then
        // P&L = (110 - 100) * 10 = 100
        // Cost basis = 100 * 10 = 1000
        // Percentage = (100 / 1000) * 100 = 10%
        XCTAssertEqual(percentage, 10.0, accuracy: 0.01)
    }
    
    func testProfitLossPercentageWithZeroCostBasis() {
        // Given
        let overview = InvestmentOverview.empty
        
        // When
        let percentage = overview.profitLossPercentage
        
        // Then
        XCTAssertEqual(percentage, 0.0, accuracy: 0.01)
    }
    
    func testIsOverallProfitable() {
        // Given - Profitable asset
        let profitableAsset = makeAsset(quantity: 1, ltp: 110.0, avgPrice: 100.0)
        let profitableOverview = InvestmentOverview.aggregate(from: [profitableAsset])
        
        // Given - Loss asset
        let lossAsset = makeAsset(quantity: 1, ltp: 90.0, avgPrice: 100.0)
        let lossOverview = InvestmentOverview.aggregate(from: [lossAsset])
        
        // Then
        XCTAssertTrue(profitableOverview.isOverallProfitable)
        XCTAssertFalse(lossOverview.isOverallProfitable)
    }
    
    func testIsDailyProfitable() {
        // Given - Positive daily change
        let positiveDailyAsset = makeAsset(quantity: 1, ltp: 110.0, close: 100.0)
        let positiveOverview = InvestmentOverview.aggregate(from: [positiveDailyAsset])
        
        // Given - Negative daily change
        let negativeDailyAsset = makeAsset(quantity: 1, ltp: 90.0, close: 100.0)
        let negativeOverview = InvestmentOverview.aggregate(from: [negativeDailyAsset])
        
        // Then
        XCTAssertTrue(positiveOverview.isDailyProfitable)
        XCTAssertFalse(negativeOverview.isDailyProfitable)
    }
    
    // MARK: - Formatting Tests
    
    func testFormattedMarketValue() {
        // Given
        let asset = makeAsset(quantity: 1, ltp: 1234.56)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let formatted = overview.formattedMarketValue()
        
        // Then
        XCTAssertEqual(formatted, "₹ 1234.56")
    }
    
    func testFormattedCostBasis() {
        // Given
        let asset = makeAsset(quantity: 1, avgPrice: 28590.71)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let formatted = overview.formattedCostBasis()
        
        // Then
        XCTAssertEqual(formatted, "₹ 28590.71")
    }
    
    func testFormattedDailyPLPositive() {
        // Given
        let asset = makeAsset(quantity: 1, ltp: 110.0, close: 100.0)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let formatted = overview.formattedDailyPL()
        
        // Then
        // Daily PNL = (100 - 110) * 1 = -10
        XCTAssertEqual(formatted, "-₹10.00")
    }
    
    func testFormattedDailyPLNegative() {
        // Given
        let asset = makeAsset(quantity: 1, ltp: 90.0, close: 100.0)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let formatted = overview.formattedDailyPL()
        
        // Then
        // Daily PNL = (100 - 90) * 1 = 10
        XCTAssertEqual(formatted, "₹ 10.00")
    }
    
    func testFormattedOverallPLPositive() {
        // Given
        let asset = makeAsset(quantity: 1, ltp: 110.0, avgPrice: 100.0)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let formatted = overview.formattedOverallPL()
        
        // Then
        // Total PNL = (110 - 100) * 1 = 10
        XCTAssertEqual(formatted, "₹10.00")
    }
    
    func testFormattedOverallPLNegative() {
        // Given
        let asset = makeAsset(quantity: 1, ltp: 90.0, avgPrice: 100.0)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let formatted = overview.formattedOverallPL()
        
        // Then
        // Total PNL = (90 - 100) * 1 = -10
        XCTAssertEqual(formatted, "-₹10.00")
    }
    
    func testFormattedPercentage() {
        // Given
        let asset = makeAsset(quantity: 10, ltp: 110.0, avgPrice: 100.0)
        let overview = InvestmentOverview.aggregate(from: [asset])
        
        // When
        let formatted = overview.formattedPercentage()
        
        // Then
        // Percentage = 10%
        XCTAssertEqual(formatted, "(10.00)%")
    }
    
    // MARK: - Empty Overview Tests
    
    func testEmptyOverview() {
        // When
        let overview = InvestmentOverview.empty
        
        // Then
        XCTAssertEqual(overview.totalMarketValue, 0.0)
        XCTAssertEqual(overview.totalCostBasis, 0.0)
        XCTAssertEqual(overview.dailyProfitLoss, 0.0)
        XCTAssertEqual(overview.overallProfitLoss, 0.0)
        XCTAssertEqual(overview.profitLossPercentage, 0.0)
    }
}


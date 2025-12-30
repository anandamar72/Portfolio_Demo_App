//
//  APIResponseTests.swift
//  PortfolioDemoAppTests
//
//  Created by Anand Amar on 30/12/25.
//

import XCTest
@testable import PortfolioDemoApp

final class APIResponseTests: XCTestCase {
    
    // MARK: - APIResponse Decoding Tests
    
    func testDecodeAPIResponseWithData() throws {
        // Given
        let json = """
        {
            "data": {
                "userHolding": [
                    {
                        "symbol": "ASHOKLEY",
                        "quantity": 3,
                        "ltp": 119.10,
                        "avgPrice": 114.80,
                        "close": 115.20
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response: InvestmentAPIResponse = try decoder.decode(InvestmentAPIResponse.self, from: json)
        
        // Then
        XCTAssertNotNil(response.payload)
        XCTAssertEqual(response.payload?.assets.count, 1)
        XCTAssertEqual(response.payload?.assets.first?.tickerSymbol, "ASHOKLEY")
    }
    
    func testDecodeAPIResponseWithEmptyHoldings() throws {
        // Given
        let json = """
        {
            "data": {
                "userHolding": []
            }
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response: InvestmentAPIResponse = try decoder.decode(InvestmentAPIResponse.self, from: json)
        
        // Then
        XCTAssertNotNil(response.payload)
        XCTAssertEqual(response.payload?.assets.count, 0)
    }
    
    func testDecodeAPIResponseWithMissingData() throws {
        // Given
        let json = """
        {
            "otherField": "value"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response: InvestmentAPIResponse = try decoder.decode(InvestmentAPIResponse.self, from: json)
        
        // Then
        XCTAssertNil(response.payload)
    }
    
    func testDecodeAPIResponseWithMultipleAssets() throws {
        // Given
        let json = """
        {
            "data": {
                "userHolding": [
                    {
                        "symbol": "ASHOKLEY",
                        "quantity": 3,
                        "ltp": 119.10,
                        "avgPrice": 114.80,
                        "close": 115.20
                    },
                    {
                        "symbol": "HDFC",
                        "quantity": 7,
                        "ltp": 2497.20,
                        "avgPrice": 2714.66,
                        "close": 2500.00
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response: InvestmentAPIResponse = try decoder.decode(InvestmentAPIResponse.self, from: json)
        
        // Then
        XCTAssertNotNil(response.payload)
        XCTAssertEqual(response.payload?.assets.count, 2)
        XCTAssertEqual(response.payload?.assets[0].tickerSymbol, "ASHOKLEY")
        XCTAssertEqual(response.payload?.assets[1].tickerSymbol, "HDFC")
    }
    
    // MARK: - InvestmentData Tests
    
    func testInvestmentDataDecoding() throws {
        // Given
        let json = """
        {
            "userHolding": [
                {
                    "symbol": "TEST",
                    "quantity": 1,
                    "ltp": 100.0,
                    "avgPrice": 100.0,
                    "close": 100.0
                }
            ]
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let data = try decoder.decode(InvestmentData.self, from: json)
        
        // Then
        XCTAssertEqual(data.assets.count, 1)
        XCTAssertEqual(data.assets.first?.tickerSymbol, "TEST")
    }
    
    func testInvestmentDataWithMissingHoldings() throws {
        // Given
        let json = """
        {
            "otherField": "value"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let data = try decoder.decode(InvestmentData.self, from: json)
        
        // Then
        XCTAssertEqual(data.assets.count, 0)
    }
    
    func testInvestmentDataInitializer() {
        // Given
        let assets = [
            StockAsset(
                tickerSymbol: "TEST",
                shareCount: 1,
                lastTradedPrice: 100.0,
                averageBuyPrice: 100.0,
                previousClosePrice: 100.0
            )
        ]
        
        // When
        let data = InvestmentData(assets: assets)
        
        // Then
        XCTAssertEqual(data.assets.count, 1)
        XCTAssertEqual(data.assets.first?.tickerSymbol, "TEST")
    }
}


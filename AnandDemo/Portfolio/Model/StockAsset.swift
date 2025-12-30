 
import UIKit

// MARK: - Stock Asset Model
/// Represents a single stock holding in the user's portfolio
struct StockAsset: Decodable, Identifiable {
    
    let id: UUID
    let tickerSymbol: String
    let shareCount: Int
    let lastTradedPrice: Double
    let averageBuyPrice: Double
    let previousClosePrice: Double
    
    private enum CodingKeys: String, CodingKey {
        case tickerSymbol = "symbol"
        case shareCount = "quantity"
        case lastTradedPrice = "ltp"
        case averageBuyPrice = "avgPrice"
        case previousClosePrice = "close"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        tickerSymbol = try container.decode(String.self, forKey: .tickerSymbol)
        shareCount = try container.decode(Int.self, forKey: .shareCount)
        lastTradedPrice = try container.decode(Double.self, forKey: .lastTradedPrice)
        averageBuyPrice = try container.decode(Double.self, forKey: .averageBuyPrice)
        previousClosePrice = try container.decode(Double.self, forKey: .previousClosePrice)
    }
    
    init(
        id: UUID = UUID(),
        tickerSymbol: String,
        shareCount: Int,
        lastTradedPrice: Double,
        averageBuyPrice: Double,
        previousClosePrice: Double
    ) {
        self.id = id
        self.tickerSymbol = tickerSymbol
        self.shareCount = shareCount
        self.lastTradedPrice = lastTradedPrice
        self.averageBuyPrice = averageBuyPrice
        self.previousClosePrice = previousClosePrice
    }
}

// MARK: - Computed Display Properties
extension StockAsset {
    
    /// Calculate profit/loss for this asset
    var profitLoss: Double {
        (lastTradedPrice - averageBuyPrice) * Double(shareCount)
    }
    
    /// Check if asset is profitable
    var isProfitable: Bool {
        profitLoss >= 0
    }
    
    /// Current market value of holdings
    var currentMarketValue: Double {
        lastTradedPrice * Double(shareCount)
    }
    
    /// Total cost basis
    var investedAmount: Double {
        averageBuyPrice * Double(shareCount)
    }
    
    /// Daily change amount
    var dailyChange: Double {
        Double(shareCount) * (previousClosePrice - lastTradedPrice)
    }
}

// MARK: - Display Item Generation
extension StockAsset {
    
    /// Generate display-ready item for table cell
    func toDisplayItem() -> AssetDisplayItem {
        AssetDisplayItem(
            symbolText: tickerSymbol,
            quantityText: "\(shareCount)",
            priceText: formatCurrency(lastTradedPrice),
            profitLossText: formatProfitLoss(profitLoss),
            indicatorColor: isProfitable ? .profitGreen : .lossRed
        )
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        "₹ \(amount)"
    }
    
    private func formatProfitLoss(_ amount: Double) -> String {
        if amount >= 0 {
            return "₹ " + String(format: "%.2f", amount)
        } else {
            return "-₹" + String(format: "%.2f", abs(amount))
        }
    }
}

// MARK: - Asset Display Item
/// View model for displaying asset in table cell
struct AssetDisplayItem {
    let symbolText: String
    let quantityText: String
    let priceText: String
    let profitLossText: String
    let indicatorColor: UIColor
}

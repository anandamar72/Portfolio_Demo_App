 
import Foundation

// MARK: - Investment Overview
/// Aggregated summary of the entire portfolio
/// Uses static factory pattern for creation from asset list
struct InvestmentOverview {
    
    let totalMarketValue: Double
    let totalCostBasis: Double
    let dailyProfitLoss: Double
    let overallProfitLoss: Double
    
    // MARK: - Computed Properties
    
    var profitLossPercentage: Double {
        guard totalCostBasis > 0 else { return 0 }
        return (overallProfitLoss / totalCostBasis) * 100
    }
    
    var isOverallProfitable: Bool {
        overallProfitLoss >= 0
    }
    
    var isDailyProfitable: Bool {
        dailyProfitLoss >= 0
    }
    
    // MARK: - Static Factory
    
    /// Create overview by aggregating from list of assets
    static func aggregate(from assets: [StockAsset]) -> InvestmentOverview {
        let marketValue = assets.reduce(0.0) { accumulator, asset in
            accumulator + asset.currentMarketValue
        }
        
        let costBasis = assets.reduce(0.0) { accumulator, asset in
            accumulator + asset.investedAmount
        }
        
        let dailyPL = assets.reduce(0.0) { accumulator, asset in
            accumulator + asset.dailyChange
        }
        
        let overallPL = marketValue - costBasis
        
        return InvestmentOverview(
            totalMarketValue: marketValue,
            totalCostBasis: costBasis,
            dailyProfitLoss: dailyPL,
            overallProfitLoss: overallPL
        )
    }
    
    /// Create empty overview
    static var empty: InvestmentOverview {
        InvestmentOverview(
            totalMarketValue: 0,
            totalCostBasis: 0,
            dailyProfitLoss: 0,
            overallProfitLoss: 0
        )
    }
}

// MARK: - Formatting Extensions
extension InvestmentOverview {
    
    func formattedMarketValue() -> String {
        "₹ " + String(format: "%.2f", totalMarketValue)
    }
    
    func formattedCostBasis() -> String {
        "₹ " + String(format: "%.2f", totalCostBasis)
    }
    
    func formattedDailyPL() -> String {
        if dailyProfitLoss >= 0 {
            return "₹ " + String(format: "%.2f", dailyProfitLoss)
        }
        return "-₹" + String(format: "%.2f", abs(dailyProfitLoss))
    }
    
    func formattedOverallPL() -> String {
        if overallProfitLoss >= 0 {
            return "₹" + String(format: "%.2f", overallProfitLoss)
        }
        return "-₹" + String(format: "%.2f", abs(overallProfitLoss))
    }
    
    func formattedPercentage() -> String {
        "(" + String(format: "%.2f", profitLossPercentage) + ")%"
    }
}

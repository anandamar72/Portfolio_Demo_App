 
import Foundation

// MARK: - API Response Wrapper
/// Unified response container that encapsulates the API response structure
/// Combines the response wrapper and data container into a single model
struct APIResponse<T: Decodable>: Decodable {
    
    let payload: T?
    
    private enum RootKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        payload = try container.decodeIfPresent(T.self, forKey: .data)
    }
}

// MARK: - Investment Data Container
/// Container for the list of stock assets from API
struct InvestmentData: Decodable {
    
    let assets: [StockAsset]
    
    private enum CodingKeys: String, CodingKey {
        case assets = "userHolding"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        assets = try values.decodeIfPresent([StockAsset].self, forKey: .assets) ?? []
    }
    
    init(assets: [StockAsset]) {
        self.assets = assets
    }
}

// MARK: - Type Alias for Convenience
typealias InvestmentAPIResponse = APIResponse<InvestmentData>

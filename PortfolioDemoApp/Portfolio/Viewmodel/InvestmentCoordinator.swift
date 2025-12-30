 
import UIKit
import Combine

// MARK: - Loading State
enum LoadingState: Equatable {
    case idle
    case fetching
    case ready
    case failed(String)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.fetching, .fetching), (.ready, .ready):
            return true
        case let (.failed(lhsMsg), .failed(rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

// MARK: - Investment Coordinator
/// Main coordinator/ViewModel using Combine and async/await
 
final class InvestmentCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var assets: [StockAsset] = []
    @Published private(set) var loadingState: LoadingState = .idle
    @Published var isDetailsPanelVisible: Bool = false
    
    // MARK: - Dependencies
    private let dataFetcher: DataFetcher
    
    // MARK: - Computed Properties
    var overview: InvestmentOverview {
        InvestmentOverview.aggregate(from: assets)
    }
    
    var assetCount: Int {
        assets.count
    }
    
    // MARK: - Initialization
    init(dataFetcher: DataFetcher = LiveDataFetcher()) {
        self.dataFetcher = dataFetcher
    }
    
    // MARK: - Public Methods
    
    /// Load assets using async/await
    func loadAssets() async {
        loadingState = .fetching
        LoadingOverlay.shared.present()
        
        do {
            let fetchedAssets = try await dataFetcher.fetchAssets()
            assets = fetchedAssets
            loadingState = .ready
        } catch {
            loadingState = .failed(error.localizedDescription)
        }
        
        LoadingOverlay.shared.dismiss()
    }
    
    /// Get display item for specific index
    func displayItem(at index: Int) -> AssetDisplayItem {
        guard index < assets.count else {
            return AssetDisplayItem(
                symbolText: "-",
                quantityText: "-",
                priceText: "-",
                profitLossText: "-",
                indicatorColor: .gray
            )
        }
        return assets[index].toDisplayItem()
    }
    
    /// Toggle details panel visibility
    func toggleDetailsPanel() {
        isDetailsPanelVisible.toggle()
    }
    
    /// Show error alert on view controller
    func presentErrorAlert(
        on controller: UIViewController,
        retryHandler: @escaping () -> Void
    ) {
        guard case .failed(let message) = loadingState else { return }
        
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            retryHandler()
        }
        
        alertController.addAction(retryAction)
        controller.present(alertController, animated: true)
    }
}

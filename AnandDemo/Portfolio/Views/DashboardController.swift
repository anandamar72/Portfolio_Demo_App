 
import UIKit
import Combine

// MARK: - Dashboard Controller
/// Main view controller for the investment dashboard

final class DashboardController: UIViewController {
    
    // MARK: - Dependencies
    private let coordinator: InvestmentCoordinator
    
    // MARK: - Combine
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var headerView = NavigationHeader()
    private lazy var tabBar = TabSelector()
    private lazy var assetList = buildTableView()
    private lazy var summaryFooter = SummaryFooterView()
    private lazy var detailsPanel = DetailedSummaryPanel()
    private lazy var statusBarBackground = buildStatusBarBackground()
    private lazy var bottomSafeAreaBackground = buildBottomBackground()
    
    // MARK: - Initialization
    init(coordinator: InvestmentCoordinator = InvestmentCoordinator()) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.coordinator = InvestmentCoordinator()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        buildViewHierarchy()
        setupConstraints()
        bindCoordinator()
        setupCallbacks()
        loadData()
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    // MARK: - View Hierarchy
    
    private func buildViewHierarchy() {
        view.addSubviews(
            statusBarBackground,
            headerView,
            tabBar,
            assetList,
            summaryFooter,
            detailsPanel,
            bottomSafeAreaBackground
        )
        
        summaryFooter.isHidden = true
        detailsPanel.isHidden = true
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        summaryFooter.translatesAutoresizingMaskIntoConstraints = false
        detailsPanel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Status Bar Background
            statusBarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),
            
            // Tab Bar
            tabBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 56),
            
            // Summary Footer
            summaryFooter.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryFooter.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryFooter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Details Panel
            detailsPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailsPanel.bottomAnchor.constraint(equalTo: summaryFooter.topAnchor),
            
            // Asset List
            assetList.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            assetList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            assetList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            assetList.bottomAnchor.constraint(equalTo: summaryFooter.topAnchor),
            
            // Bottom Safe Area Background
            bottomSafeAreaBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSafeAreaBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSafeAreaBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSafeAreaBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Combine Bindings
    
    private func bindCoordinator() {
        coordinator.$loadingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &subscriptions)
        
        coordinator.$isDetailsPanelVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.updateDetailsPanelVisibility(isVisible)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Callbacks
    
    private func setupCallbacks() {
        summaryFooter.onExpandTapped = { [weak self] in
            self?.coordinator.toggleDetailsPanel()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        Task {
            await coordinator.loadAssets()
        }
    }
    
    // MARK: - State Handling
    
    private func handleStateChange(_ state: LoadingState) {
        switch state {
        case .idle, .fetching:
            break
            
        case .ready:
            assetList.reloadData()
            updateSummaryViews()
            summaryFooter.isHidden = false
            addBottomBackground()
            
        case .failed:
            coordinator.presentErrorAlert(on: self) { [weak self] in
                self?.loadData()
            }
        }
    }
    
    private func updateSummaryViews() {
        let overview = coordinator.overview
        summaryFooter.update(with: overview, isExpanded: coordinator.isDetailsPanelVisible)
        detailsPanel.update(with: overview)
    }
    
    private func updateDetailsPanelVisibility(_ isVisible: Bool) {
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve) {
            self.detailsPanel.isHidden = !isVisible
        }
        updateSummaryViews()
    }
    
    private func addBottomBackground() {
        bottomSafeAreaBackground.isHidden = false
    }
    
    // MARK: - Component Builders
    
    private func buildTableView() -> UITableView {
        let table = UITableView()
        table.register(AssetTableCell.self, forCellReuseIdentifier: AssetTableCell.reuseID)
        table.dataSource = self
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }
    
    private func buildStatusBarBackground() -> UIView {
        let view = UIView()
        view.backgroundColor = .primaryNavy
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func buildBottomBackground() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }
}

// MARK: - UITableViewDataSource
extension DashboardController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coordinator.assetCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AssetTableCell.reuseID,
            for: indexPath
        ) as? AssetTableCell else {
            return UITableViewCell()
        }
        
        cell.bind(coordinator.displayItem(at: indexPath.row))
        return cell
    }
}

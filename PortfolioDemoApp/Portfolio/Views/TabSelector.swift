 
import UIKit

// MARK: - Tab Selector
/// Segmented control for positions/holdings tabs
final class TabSelector: UIView {
    
    // MARK: - Types
    enum Tab {
        case positions
        case holdings
    }
    
    // MARK: - Callbacks
    var onTabSelected: ((Tab) -> Void)?
    
    // MARK: - UI Components
    private lazy var positionsTab = createTabButton(title: "POSITIONS")
    private lazy var holdingsTab = createTabButton(title: "HOLDINGS")
    private lazy var indicator = createIndicator()
    private var indicatorCenterConstraint: NSLayoutConstraint!
    
    // MARK: - State
    private var selectedTab: Tab = .holdings
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        layoutComponents()
        selectTab(.holdings, animated: false)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Storyboard initialization not supported")
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        backgroundColor = .white
    }
    
    private func layoutComponents() {
        let tabStack = UIStackView.create(
            axis: .horizontal,
            distribution: .fillEqually,
            views: [positionsTab, holdingsTab]
        )
        
        addSubviews(tabStack, indicator)
        
        indicatorCenterConstraint = indicator.centerXAnchor.constraint(equalTo: holdingsTab.centerXAnchor)
        
        NSLayoutConstraint.activate([
            tabStack.topAnchor.constraint(equalTo: topAnchor),
            tabStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            indicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            indicator.heightAnchor.constraint(equalToConstant: 2),
            indicator.widthAnchor.constraint(equalToConstant: 70),
            indicatorCenterConstraint
        ])
    }
    
    // MARK: - Factory Methods
    
    private func createTabButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.lightGray, for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }
    
    private func createIndicator() -> UIView {
        let view = UIView()
        view.backgroundColor = .selectionIndicator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    // MARK: - Tab Selection
    
    private func selectTab(_ tab: Tab, animated: Bool) {
        selectedTab = tab
        
        let isPositions = tab == .positions
        positionsTab.setTitleColor(isPositions ? .black : .lightGray, for: .normal)
        holdingsTab.setTitleColor(isPositions ? .lightGray : .black, for: .normal)
        
        removeConstraint(indicatorCenterConstraint)
        indicatorCenterConstraint = indicator.centerXAnchor.constraint(
            equalTo: isPositions ? positionsTab.centerXAnchor : holdingsTab.centerXAnchor
        )
        indicatorCenterConstraint.isActive = true
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
        
        onTabSelected?(tab)
    }
    
    // MARK: - Actions
    
    @objc private func positionsPressed() {
        selectTab(.positions, animated: true)
    }
    
    @objc private func holdingsPressed() {
        selectTab(.holdings, animated: true)
    }
}

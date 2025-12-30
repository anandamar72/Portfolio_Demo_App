 
import UIKit

// MARK: - Detailed Summary Panel
/// Expanded panel showing detailed investment metrics
final class DetailedSummaryPanel: UIView {
    
    // MARK: - UI Components
    private lazy var marketValueRow = buildMetricRow(title: "Current value")
    private lazy var costBasisRow = buildMetricRow(title: "Total investment")
    private lazy var dailyPnlRow = buildMetricRow(title: "Today's Profit & Loss")
    private lazy var divider = buildDivider()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        buildLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Storyboard initialization not supported")
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        backgroundColor = .lightBackground
    }
    
    func update(with overview: InvestmentOverview) {
        marketValueRow.value.text = overview.formattedMarketValue()
        marketValueRow.value.textColor = .subtleGray
        
        costBasisRow.value.text = overview.formattedCostBasis()
        costBasisRow.value.textColor = .subtleGray
        
        dailyPnlRow.value.text = overview.formattedDailyPL()
        dailyPnlRow.value.textColor = overview.isDailyProfitable ? .profitGreen : .lossRed
    }
    
    // MARK: - Layout
    
    private func buildLayout() {
        addSubviews(
            marketValueRow.container,
            costBasisRow.container,
            dailyPnlRow.container,
            divider
        )
        
        NSLayoutConstraint.activate([
            // Market Value Row
            marketValueRow.container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            marketValueRow.container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            marketValueRow.container.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            
            // Cost Basis Row
            costBasisRow.container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            costBasisRow.container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            costBasisRow.container.topAnchor.constraint(equalTo: marketValueRow.container.bottomAnchor, constant: 24),
            
            // Daily P&L Row
            dailyPnlRow.container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dailyPnlRow.container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dailyPnlRow.container.topAnchor.constraint(equalTo: costBasisRow.container.bottomAnchor, constant: 24),
            
            // Divider
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            divider.topAnchor.constraint(equalTo: dailyPnlRow.container.bottomAnchor, constant: 24),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Component Builders
    
    private func buildMetricRow(title: String) -> (container: UIStackView, value: UILabel) {
        let titleLabel = UILabel.create(
            text: title,
            font: .systemFont(ofSize: 16),
            textColor: .subtleGray
        )
        
        let valueLabel = UILabel.create(
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .subtleGray
        )
        
        let stack = UIStackView.create(
            axis: .horizontal,
            alignment: .center,
            distribution: .equalSpacing,
            views: [titleLabel, valueLabel]
        )
        stack.backgroundColor = .lightBackground
        
        return (stack, valueLabel)
    }
    
    private func buildDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .dividerGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

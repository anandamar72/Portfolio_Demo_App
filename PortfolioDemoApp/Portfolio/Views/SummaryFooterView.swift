 

import UIKit

// MARK: - Summary Footer View
/// Collapsible footer showing P&L summary
final class SummaryFooterView: UIView {
    
    // MARK: - Callbacks
    var onExpandTapped: (() -> Void)?
    
    // MARK: - UI Components
    private lazy var titleLabel = buildTitleLabel()
    private lazy var expandIcon = buildExpandIcon()
    private lazy var amountLabel = buildAmountLabel()
    private lazy var percentageLabel = buildPercentageLabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        buildLayout()
        addTapHandler()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Storyboard initialization not supported")
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        backgroundColor = .lightBackground
    }
    
    func update(with overview: InvestmentOverview, isExpanded: Bool) {
        percentageLabel.text = overview.formattedPercentage()
        amountLabel.text = overview.formattedOverallPL()
        
        let indicatorColor: UIColor = overview.isOverallProfitable ? .profitGreen : .lossRed
        amountLabel.textColor = indicatorColor
        percentageLabel.textColor = indicatorColor
        
        let iconName = isExpanded ? "chevron.down" : "chevron.up"
        expandIcon.image = UIImage(systemName: iconName)
    }
    
    // MARK: - Layout
    
    private func buildLayout() {
        addSubviews(titleLabel, expandIcon, percentageLabel, amountLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            expandIcon.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            expandIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            percentageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            percentageLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: percentageLabel.leadingAnchor, constant: -2),
            amountLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
    
    // MARK: - Tap Handler
    
    private func addTapHandler() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        expandIcon.addGestureRecognizer(tapGesture)
        expandIcon.isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        onExpandTapped?()
    }
    
    // MARK: - Component Builders
    
    private func buildTitleLabel() -> UILabel {
        UILabel.create(
            text: "Profit & Loss",
            font: .systemFont(ofSize: 16),
            textColor: .black
        )
    }
    
    private func buildExpandIcon() -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.up"))
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func buildAmountLabel() -> UILabel {
        UILabel.create(
            font: .systemFont(ofSize: 16),
            textColor: .black
        )
    }
    
    private func buildPercentageLabel() -> UILabel {
        UILabel.create(
            font: .systemFont(ofSize: 12),
            textColor: .lossRed
        )
    }
}

 
import UIKit

// MARK: - Asset Table Cell
/// Custom table view cell for displaying stock assets
final class AssetTableCell: UITableViewCell {
    
    // MARK: - Constants
    static let reuseID = "AssetTableCell"
    
    // MARK: - UI Components
    private lazy var separatorLine = buildSeparator()
    private lazy var tickerLabel = buildTickerLabel()
    private lazy var priceLabel = buildValueLabel()
    private lazy var priceTitleLabel = buildDescriptionLabel(text: "LTP: ")
    private lazy var quantityTitleLabel = buildDescriptionLabel(text: "NET QTY: ")
    private lazy var quantityLabel = buildValueLabel()
    private lazy var pnlTitleLabel = buildDescriptionLabel(text: "P&L: ")
    private lazy var pnlLabel = buildValueLabel()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Storyboard initialization not supported")
    }
    
    // MARK: - Configuration
    
    func bind(_ item: AssetDisplayItem) {
        tickerLabel.text = item.symbolText
        priceLabel.text = item.priceText
        quantityLabel.text = item.quantityText
        pnlLabel.text = item.profitLossText
        pnlLabel.textColor = item.indicatorColor
    }
    
    // MARK: - Layout Building
    
    private func buildLayout() {
        contentView.addSubviews(
            separatorLine,
            tickerLabel,
            priceTitleLabel,
            priceLabel,
            quantityTitleLabel,
            quantityLabel,
            pnlTitleLabel,
            pnlLabel
        )
        
        NSLayoutConstraint.activate([
            // Separator
            separatorLine.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Ticker
            tickerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tickerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            // Price (Top Right)
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: tickerLabel.centerYAnchor),
            
            priceTitleLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -4),
            priceTitleLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            
            // Quantity (Bottom Left)
            quantityTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quantityTitleLabel.topAnchor.constraint(equalTo: tickerLabel.bottomAnchor, constant: 24),
            quantityTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            quantityLabel.leadingAnchor.constraint(equalTo: quantityTitleLabel.trailingAnchor, constant: 4),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityTitleLabel.centerYAnchor),
            
            // P&L (Bottom Right)
            pnlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pnlLabel.centerYAnchor.constraint(equalTo: quantityTitleLabel.centerYAnchor),
            
            pnlTitleLabel.trailingAnchor.constraint(equalTo: pnlLabel.leadingAnchor, constant: -4),
            pnlTitleLabel.centerYAnchor.constraint(equalTo: pnlLabel.centerYAnchor)
        ])
    }
    
    // MARK: - Component Builders
    
    private func buildSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func buildTickerLabel() -> UILabel {
        UILabel.create(
            font: .systemFont(ofSize: 16, weight: .semibold),
            textColor: .label
        )
    }
    
    private func buildValueLabel() -> UILabel {
        UILabel.create(
            font: .systemFont(ofSize: 14),
            textColor: .label
        )
    }
    
    private func buildDescriptionLabel(text: String) -> UILabel {
        UILabel.create(
            text: text,
            font: .systemFont(ofSize: 12),
            textColor: .secondaryLabel
        )
    }
}

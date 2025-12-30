 
import UIKit

// MARK: - Navigation Header
/// Top navigation bar view
final class NavigationHeader: UIView {
    
    // MARK: - UI Components
    private lazy var userIcon = createUserIcon()
    private lazy var titleText = createTitleLabel()
    private lazy var actionButtons = createActionStack()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        layoutComponents()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Storyboard initialization not supported")
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        backgroundColor = .primaryNavy
    }
    
    private func layoutComponents() {
        addSubviews(userIcon, titleText, actionButtons)
        
        NSLayoutConstraint.activate([
            // User Icon
            userIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            userIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            userIcon.widthAnchor.constraint(equalToConstant: 28),
            userIcon.heightAnchor.constraint(equalToConstant: 28),
            
            // Title
            titleText.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleText.leadingAnchor.constraint(equalTo: userIcon.trailingAnchor, constant: 12),
            
            // Action Buttons
            actionButtons.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionButtons.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Factory Methods
    
    private func createUserIcon() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .white
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel.create(
            text: "Portfolio",
            font: .systemFont(ofSize: 18, weight: .medium),
            textColor: .white
        )
        return label
    }
    
    private func createActionStack() -> UIStackView {
        let sortButton = createActionButton(systemName: "arrow.up.arrow.down")
        let searchButton = createActionButton(systemName: "magnifyingglass")
        
        let stack = UIStackView.create(
            axis: .horizontal,
            spacing: 16,
            views: [sortButton, searchButton]
        )
        return stack
    }
    
    private func createActionButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .white
        button.isUserInteractionEnabled = false
        return button
    }
}

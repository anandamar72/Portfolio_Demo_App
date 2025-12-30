 
import UIKit

// MARK: - Color Palette
extension UIColor {
    
    /// Create color from hex string
    static func fromHex(_ hexString: String) -> UIColor {
        var sanitized = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }
        
        guard sanitized.count == 6 else {
            return .systemGray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgbValue)
        
        let redComponent = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        return UIColor(
            red: redComponent,
            green: greenComponent,
            blue: blueComponent,
            alpha: 1.0
        )
    }
    
    // MARK: - App Colors
    
    static var primaryNavy: UIColor {
        .fromHex("#033364")
    }
    
    static var profitGreen: UIColor {
        .fromHex("#33d6a1")
    }
    
    static var lossRed: UIColor {
        .fromHex("#CD5963")
    }
    
    static var lightBackground: UIColor {
        .fromHex("#F5F5F5")
    }
    
    static var subtleGray: UIColor {
        .fromHex("#5E5E5E")
    }
    
    static var dividerGray: UIColor {
        .fromHex("#cfcfcf")
    }
    
    static var selectionIndicator: UIColor {
        .fromHex("#d1d1d1")
    }
}

// MARK: - Double Formatting
extension Double {
    
    /// Truncate to two decimal places
    var truncatedToTwoDecimals: Double {
        let truncated = floor(self * 100) / 100
        let timesTen = truncated * 10
        return timesTen == floor(timesTen) ? floor(timesTen) / 10 : truncated
    }
    
    /// Format as currency string
    func asCurrency(symbol: String = "₹") -> String {
        "\(symbol) \(String(format: "%.2f", self))"
    }
}

// MARK: - View Builder Helpers
extension UIView {
    
    /// Disable autoresizing mask translation
    @discardableResult
    func withAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    /// Add multiple subviews at once
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

// MARK: - Label Factory
extension UILabel {
    
    /// Create configured label
    static func create(
        text: String? = nil,
        font: UIFont = .systemFont(ofSize: 14),
        textColor: UIColor = .label,
        alignment: NSTextAlignment = .natural
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

// MARK: - Stack View Factory
extension UIStackView {
    
    /// Create configured stack view
    static func create(
        axis: NSLayoutConstraint.Axis = .horizontal,
        spacing: CGFloat = 0,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        views: [UIView] = []
    ) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}

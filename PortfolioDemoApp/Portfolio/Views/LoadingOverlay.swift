 
import UIKit

// MARK: - Loading Overlay
/// Singleton overlay for displaying loading state
final class LoadingOverlay {
    
    // MARK: - Singleton
    static let shared = LoadingOverlay()
    
    // MARK: - Private Properties
    private var overlayView: UIVisualEffectView?
    private var spinner: UIActivityIndicatorView?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Show loading overlay
    func present() {
        DispatchQueue.main.async { [weak self] in
            self?.showOverlay()
        }
    }
    
    /// Hide loading overlay
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.hideOverlay()
        }
    }
    
    // MARK: - Private Methods
    
    private func showOverlay() {
        guard overlayView == nil else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first else {
            return
        }
        
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = keyWindow.bounds
        blurredView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activitySpinner = UIActivityIndicatorView(style: .large)
        activitySpinner.color = .primaryNavy
        activitySpinner.translatesAutoresizingMaskIntoConstraints = false
        activitySpinner.startAnimating()
        
        blurredView.contentView.addSubview(activitySpinner)
        
        NSLayoutConstraint.activate([
            activitySpinner.centerXAnchor.constraint(equalTo: blurredView.centerXAnchor),
            activitySpinner.centerYAnchor.constraint(equalTo: blurredView.centerYAnchor)
        ])
        
        keyWindow.addSubview(blurredView)
        
        overlayView = blurredView
        spinner = activitySpinner
    }
    
    private func hideOverlay() {
        spinner?.stopAnimating()
        overlayView?.removeFromSuperview()
        overlayView = nil
        spinner = nil
    }
}

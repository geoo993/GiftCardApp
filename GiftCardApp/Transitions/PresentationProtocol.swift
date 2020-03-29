
import UIKit

protocol PresentationProtocol {
    
    // MARK: - 
    
    var presentationManager: PresentationManager { get set }
    func present(model viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
}

// MARK: -

extension PresentationProtocol where Self: UIViewController {
    
    // MARK: - Default Present
    
    func present(model viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = UIModalPresentationStyle.custom
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = false
        }
        viewController.transitioningDelegate = presentationManager
        present(viewController, animated: true, completion: nil)
    }
}


import UIKit

final class PresentationManager: NSObject {
    
    // MARK: - Directions
    
    enum PresentationDirection {
        
        // MARK: - Case
        
        case left
        case top
        case right
        case bottom
    }
    
    // MARK: - Scale
    
    enum PresentationSize {
        
        // MARK: - Case
        
        case full
        case third
        case half
        case custom(CGFloat)
    }
    
    // MARK: - Properties
    
    let direction: PresentationDirection
    let size: PresentationSize
    let disableCompactHeight: Bool
    var presentationController: PresentationController!
    
    // MARK: - Initializer
    
    init(direction: PresentationDirection, size: PresentationSize, disableCompactHeight: Bool) {
        self.direction = direction
        self.size = size
        self.disableCompactHeight = disableCompactHeight
        super.init()
    }
}

// MARK: -

extension PresentationManager: UIViewControllerTransitioningDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presentationController = PresentationController(presentedViewController: presented, presenting: presenting, presentationStyle: .direction(direction), .size(size), .background(.dimmed))
        presentationController.delegate = self
        return presentationController
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
   
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(direction: direction, isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(direction: direction, isPresentation: false)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let controller = presentationController else { return nil }
        return controller.isInteractive ? controller.interactor : nil
    }
}

// MARK: -

extension PresentationManager: UIAdaptivePresentationControllerDelegate {
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
          return .overFullScreen
        } else {
          return .none
        }
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
//        guard case(.overFullScreen) = style else { return nil }
//        return UIStoryboard(name: "Main", bundle: nil)
//          .instantiateViewController(withIdentifier: "RotateViewController")
        return nil
    }
}

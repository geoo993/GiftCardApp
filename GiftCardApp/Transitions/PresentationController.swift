
// https://stackoverflow.com/questions/42106980/how-to-present-a-viewcontroller-on-half-screen
// https://github.com/martinnormark/HalfModalPresentationController/blob/master/HalfModalPresentationController/Presentation/HalfModalPresentationController.swift
// https://medium.com/@qbo/dismiss-viewcontrollers-presented-modally-using-swipe-down-923cfa9d22f4
// https://github.com/sgr-ksmt/PullToDismiss
// https://itnext.io/pull-to-dismiss-modal-presentation-in-ios-d6284434c860
// https://github.com/benguild/PullToDismissTransition
// https://stackoverflow.com/questions/26680311/interactive-delegate-methods-never-called
// https://www.raywenderlich.com/322-custom-uiviewcontroller-transitions-getting-started
// https://gist.github.com/vinczebalazs/ee1f2b466f969fa70d424d4480695325

import UIKit

final class PresentationController: UIPresentationController {
    
    // MARK: - UIConstants
    
    fileprivate enum UIConstants {
        static let cornerRadius: CGFloat = 8.0
        static let backgroundBlur: CGFloat = 0.9
        static let backgroundAlpha: CGFloat = 0.6
        static let minimunHeightRatio: CGFloat = 0.1
        static let maximumTouchOffset: CGFloat = 100.0
    }
    
    // MARK: - Presentation Style
    
    enum PresentationStyle {
        
        case direction(PresentationManager.PresentationDirection)
        case size(PresentationManager.PresentationSize)
        case background(BackgroundViewStyle)
    }
    
    // MARK: - Properties
    
    private var isMaximized: Bool = false
    private var panDirection: CGFloat?
    private var panInitialTouchPoint: CGPoint?
    private (set)var isInteractive = true
    private var shouldCompleteTransition = false
    private (set)var interactor = UIPercentDrivenInteractiveTransition()
    private var direction: PresentationManager.PresentationDirection = .bottom
    private var size: PresentationManager.PresentationSize = .full
    private var preferredFrame: (origin: CGPoint, size: CGSize) {
        let containerViewFrame = self.containerView?.bounds ?? UIScreen.main.bounds
        switch size {
        case .full:
            return (containerViewFrame.origin, containerViewFrame.size)
        case .third:
            switch direction {
            case .left:
                return (CGPoint.zero, CGSize(width: containerViewFrame.width * 0.666666666, height: containerViewFrame.height))
            case .right:
                return (CGPoint(x: containerViewFrame.width * 0.333333333, y: 0), CGSize(width: containerViewFrame.width * 0.666666666, height: containerViewFrame.height))
            case .top:
                return (CGPoint.zero, CGSize(width: containerViewFrame.width, height: containerViewFrame.height * 0.666666666))
            case .bottom:
                return (CGPoint(x: 0, y: containerViewFrame.height * 0.333333333), CGSize(width: containerViewFrame.width, height: containerViewFrame.height * 0.666666666))
            }
        case .half:
            switch direction {
            case .left:
                return (CGPoint.zero, CGSize(width: containerViewFrame.width * 0.5, height: containerViewFrame.height))
            case .right:
                return (CGPoint(x: containerViewFrame.width * 0.5, y: 0), CGSize(width: containerViewFrame.width * 0.5, height: containerViewFrame.height))
            case .top:
                return (CGPoint.zero, CGSize(width: containerViewFrame.width, height: containerViewFrame.height * 0.5))
            case .bottom:
                return (CGPoint(x: 0, y: containerViewFrame.height * 0.5), CGSize(width: containerViewFrame.width, height: containerViewFrame.height * 0.5))
            }
        case .custom(let amount):
            let width = max(amount, containerViewFrame.width * UIConstants.minimunHeightRatio)
            let height = max(amount, containerViewFrame.height * UIConstants.minimunHeightRatio)
            switch direction {
            case .left:
                return (CGPoint.zero, CGSize(width: width, height: containerViewFrame.height))
            case .right:
                return (CGPoint(x: containerViewFrame.width - width, y: 0), CGSize(width: width, height: containerViewFrame.height))
            case .top:
                return (CGPoint.zero, CGSize(width: containerViewFrame.width, height: height))
            case .bottom:
                return (CGPoint(x: 0, y: containerViewFrame.height - height), CGSize(width: containerViewFrame.width, height: height))
            }
        }
    }
    
    // MARK: Background View
    
    enum BackgroundViewStyle {
        
        case blurred
        case dimmed
        case colored(UIColor)
        case image(UIImage?)
    }
    
    private var backgroundViewStyle: BackgroundViewStyle = .dimmed
    private var backgroundViewAlpha: CGFloat = 1.0
    private var background: UIView?
    var backgroundView: UIView {
        if let background = background {
            return background
        }
        
        let size = preferredFrame.size
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        
        switch backgroundViewStyle {
        case .blurred:
            
            // Blur Effect
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.isUserInteractionEnabled = true
            view.addSubview(blurEffectView)
            
            // Vibrancy Effect
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyEffectView.frame = view.bounds
            
            // Add the vibrancy view to the blur view
            blurEffectView.contentView.addSubview(vibrancyEffectView)
            backgroundViewAlpha = UIConstants.backgroundBlur
        case .dimmed:
            backgroundViewAlpha = UIConstants.backgroundAlpha
            view.backgroundColor = UIColor(white: 0.0, alpha: UIConstants.backgroundAlpha)
        
        case .colored(let color):
            backgroundViewAlpha = 1.0
            view.backgroundColor = color
        
        case .image(let image):
            backgroundViewAlpha = 1.0
            let imageView = UIImageView(image: image)
            imageView.frame = view.bounds
            imageView.contentMode =  .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.center = view.center
            view.insertSubview(imageView, at: 0)
        }
        
        background = view
        
        return view
    }
    
    // MARK: - Presentation Frame
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard containerView != nil else {
           return CGRect.zero
        }
        return CGRect(origin: preferredFrame.origin, size: preferredFrame.size)
    }
    
    // MARK: - Initializer
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,
         presentationStyle: PresentationStyle...) {
        for style in presentationStyle {
            switch style {
            case .direction(let direction):
                self.direction = direction
            case .size(let size):
                self.size = size
            case .background(let style):
                self.backgroundViewStyle = style
            }
        }
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
        presentedViewController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onPan(_:))))
    }

    // MARK: - Presentation Cycle
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        backgroundView.alpha = 0
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["backgroundView": backgroundView]))

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["backgroundView": backgroundView]))

        backgroundView.addSubview(presentedViewController.view)
        presentedViewController.didMove(toParent: presentingViewController)

        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.alpha = backgroundViewAlpha
            return
        }

        coordinator.animate(alongsideTransition: { [weak self] _ -> Void in
            guard let self = self else { return }
            self.backgroundView.alpha = self.backgroundViewAlpha
        })

    }

    override func presentationTransitionDidEnd(_ completed: Bool) {

        if completed, let containerView = containerView {
            backgroundView.frame = containerView.bounds
        }

    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { [weak self] _ -> Void in
            self?.backgroundView.alpha = 0.0
        })
    
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        if completed {
            backgroundView.removeFromSuperview()
            background = nil
            isMaximized = false
        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let presentedView = presentedView else { return }
        presentedView.layer.masksToBounds = true
        presentedView.layer.cornerRadius = UIConstants.cornerRadius
        switch direction {
        case .left:
            presentedView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .right:
            presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .top:
            presentedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .bottom:
            presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        presentedView.frame = frameOfPresentedViewInContainerView
    }

    override func containerViewDidLayoutSubviews() {
       super.containerViewDidLayoutSubviews()

       if let containerView = containerView {
           backgroundView.frame = containerView.bounds
       }
    }
    
    // MARK: - Actions
    
    @objc private func onTap(_ tap: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        guard let view = pan.view,
            pan.translation(in: view.superview).y >= 0 else { return } // Make sure we only recognize downward gestures.
        
        var progress = pan.translation(in: view.superview).y / view.bounds.height
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch pan.state {
        case .began:
            isInteractive = true
            presentingViewController.dismiss(animated: true)
        case .changed:
            let velocity = pan.velocity(in: view.superview).y
            shouldCompleteTransition = progress > 0.5 || velocity > 1600
            interactor.update(progress)
        case .cancelled:
            isInteractive = false
            interactor.cancel()
        case .ended:
            isInteractive = false
            let velocity = pan.velocity(in: view).y
            // Finish the animation if the user flicked the modal quickly (i.e. high velocity), or dragged it more than 50% down.
            //if progress > 0.5 || velocity > 1600 {
            if shouldCompleteTransition {
                // Multiply the animation duration by the velocity, to make sure the modal dismisses as fast as the user swiped.
                // If the user pulled down slowly though, we want to use the default duration, hence the max().
                interactor.completionSpeed = max(1, velocity / (view.frame.height * (1 / interactor.duration)))
                interactor.finish()
            } else {
                interactor.cancel()
            }
        default:
            break
        }
    }
    /*
    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        let touchPoint = pan.translation(in: pan.view?.superview)
        switch pan.state {
        case .began:
            presentedView?.frame.size.height = preferredFrame.size.height
            panInitialTouchPoint = touchPoint
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            guard let startingPosition = panInitialTouchPoint else { return }
            let goingDown = touchPoint.y > 0 && touchPoint.y - startingPosition.y < UIConstants.maximumTouchOffset
            let goingUp = touchPoint.y < 0 && startingPosition.y - touchPoint.y < UIConstants.maximumTouchOffset
            let goingRight = touchPoint.x > 0 && touchPoint.x - startingPosition.x < UIConstants.maximumTouchOffset
            let goingLeft = touchPoint.x < 0 && startingPosition.x - touchPoint.x < UIConstants.maximumTouchOffset
        switch direction {
        case .top:
            if goingUp {
                presentedView?.frame =
                    CGRect(x: preferredFrame.origin.x,
                           y: (touchPoint.y - startingPosition.y) + preferredFrame.origin.y,
                           width: preferredFrame.size.width, height: preferredFrame.size.height)
            } else if touchPoint.y < -UIConstants.maximumTouchOffset {
                pan.isEnabled = false
            }
            panDirection = velocity.y
        case .bottom:
            if goingDown {
                presentedView?.frame =
                    CGRect(x: preferredFrame.origin.x,
                           y: touchPoint.y + preferredFrame.origin.y,
                           width: preferredFrame.size.width, height: preferredFrame.size.height)
            } else if touchPoint.y > UIConstants.maximumTouchOffset {
                pan.isEnabled = false
            }
            panDirection = velocity.y
        case .left:
            if goingLeft {
            presentedView?.frame =
                    CGRect(x: (touchPoint.x - startingPosition.x) + preferredFrame.origin.x,
                           y: preferredFrame.origin.y,
                           width: preferredFrame.size.width, height: preferredFrame.size.height)
            } else if touchPoint.x < -UIConstants.maximumTouchOffset {
                pan.isEnabled = false
            }
            panDirection = velocity.x
        case .right:
            if goingRight {
                presentedView?.frame =
                    CGRect(x: touchPoint.x + preferredFrame.origin.x,
                           y: preferredFrame.origin.y,
                           width: preferredFrame.size.width, height: preferredFrame.size.height)
            } else if touchPoint.x > UIConstants.maximumTouchOffset {
                pan.isEnabled = false
            }
            panDirection = velocity.x
        }

        case .ended, .cancelled:

            guard let startingPosition = panInitialTouchPoint, let panDirection = panDirection else { return }
            let dismiss: Bool
            switch direction {
            case .top:
                dismiss = panDirection < 0.0 && startingPosition.y - touchPoint.y > UIConstants.maximumTouchOffset
            case .bottom:
                dismiss = panDirection > 0.0 && touchPoint.y - startingPosition.y > UIConstants.maximumTouchOffset
            case .left:
                dismiss = panDirection < 0.0 && startingPosition.x - touchPoint.x > UIConstants.maximumTouchOffset
            case .right:
                dismiss = panDirection > 0.0 && touchPoint.x - startingPosition.x > UIConstants.maximumTouchOffset
            }
            
            if dismiss {
               presentingViewController.dismiss(animated: true, completion: nil)
            } else {
               // snap back to position
                if let presentedView = presentedView {
                    UIView.animate(withDuration: 0.2, animations: { [weak self] () -> Void in
                        guard let self = self else { return }
                        presentedView.frame = CGRect(origin: self.preferredFrame.origin, size: self.preferredFrame.size)
                        
                        if let navController = self.presentedViewController as? UINavigationController {
                            self.isMaximized = true
                            
                            navController.setNeedsStatusBarAppearanceUpdate()
                            
                            // Force the navigation bar to update its size
                            navController.isNavigationBarHidden = true
                            navController.isNavigationBarHidden = false
                        }
                    }, completion: nil)
                }
            }

        default: break
        }
    }
 */
}

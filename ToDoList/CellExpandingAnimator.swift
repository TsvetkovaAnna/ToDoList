
import UIKit

class CellExpandingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.5
    let sourceFrame: CGRect?
    
    init(for sourceFrame: CGRect?) {
        self.sourceFrame = sourceFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: .to), let sourceFrame = sourceFrame else { return }
        transitionContext.containerView.addSubview(destination.view)
        
        let scaleY = sourceFrame.height/destination.view.frame.height
        let scaleTransform = CGAffineTransform(scaleX: 1, y: scaleY)
        destination.view.transform = scaleTransform
        destination.view.frame.origin.y = sourceFrame.origin.y
        
        UIView.animate(withDuration: duration) {
            destination.view.transform = .identity
            destination.view.frame.origin.y = .zero
        } completion: { _ in
            transitionContext.completeTransition(true)
        }

    }
    
}

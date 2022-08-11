

import UIKit

class TransitionNavigationController: UINavigationController {
    
    var sourceFrame: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
    }
    
}

extension TransitionNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        sourceFrame?.origin.y += statusBarHeight + navigationBar.frame.height
        let animator = CellExpandingAnimator(for: sourceFrame)
        return operation == .push ? animator : nil
    }
}

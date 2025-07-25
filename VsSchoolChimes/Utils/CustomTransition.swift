//
//  CustomTransition.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/07/25.
//

import Foundation
import UIKit

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {

    var originFrame: CGRect = .zero
    var isPresenting: Bool = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView

        let detailView = isPresenting ? toVC.view! : fromVC.view!
        let initialFrame = isPresenting ? originFrame : detailView.frame
        let finalFrame = isPresenting ? containerView.frame : originFrame

        if isPresenting {
            detailView.frame = initialFrame
            detailView.layer.cornerRadius = 12
            detailView.clipsToBounds = true
            containerView.addSubview(detailView)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut],
                       animations: {
            detailView.frame = finalFrame
            detailView.layer.cornerRadius = self.isPresenting ? 0 : 12
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let customTransition = CustomTransition()
    var originFrame: CGRect = .zero

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        customTransition.originFrame = originFrame
        customTransition.isPresenting = true
        return customTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        customTransition.isPresenting = false
        return customTransition
    }
}

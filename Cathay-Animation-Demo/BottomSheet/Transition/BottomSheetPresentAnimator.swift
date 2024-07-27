//
//  BottomSheetPresentAnimator.swift
//  GouGouLiu
//
//  Created by HarryCao on 2024/6/12.
//

import UIKit

final class BottomSheetPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private weak var dimmingView: UIView?

    init(dimmingView: UIView) {
        self.dimmingView = dimmingView
    }

    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.3
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        toView.frame = containerView.bounds.offsetBy(dx: 0, dy: containerView.bounds.height)
        containerView.addSubview(toView)
        dimmingView?.alpha = 0

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: {
            toView.frame = containerView.bounds.offsetBy(dx: 0, dy: 0)
            self.dimmingView?.alpha = 1
        }, completion: { finished in
            let complete = transitionContext.transitionWasCancelled ? false : finished
            transitionContext.completeTransition(complete)
        })
    }
}

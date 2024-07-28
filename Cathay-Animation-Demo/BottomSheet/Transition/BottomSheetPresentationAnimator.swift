//
//  BottomSheetPresentationAnimator.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/28.
//

import UIKit

final class BottomSheetPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let transitionStyle: TransitionStyle

    init(transitionStyle: TransitionStyle) {
        self.transitionStyle = transitionStyle
    }

    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        switch transitionStyle {
        case .presentation:
            animatePresentation(transitionContext: transitionContext)
        case .dismissal:
            animateDismissal(transitionContext: transitionContext)
        }
    }
}

extension BottomSheetPresentationAnimator {
    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        toView.frame = containerView.bounds.offsetBy(dx: 0, dy: containerView.bounds.height)
        containerView.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {
            toView.frame.origin.y = BottomSheetConstrants.contentHeight
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }

    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {
            fromView.frame.origin.y = containerView.frame.height
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

extension BottomSheetPresentationAnimator {
    enum TransitionStyle {
        case presentation
        case dismissal
    }
}

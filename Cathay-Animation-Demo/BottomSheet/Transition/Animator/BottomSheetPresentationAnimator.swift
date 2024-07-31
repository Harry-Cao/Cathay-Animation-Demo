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

    private func panModalLayoutType(from context: UIViewControllerContextTransitioning) -> BottomSheetPresentable.LayoutType? {
        switch transitionStyle {
        case .presentation:
            return context.viewController(forKey: .to) as? BottomSheetPresentable.LayoutType
        case .dismissal:
            return context.viewController(forKey: .from) as? BottomSheetPresentable.LayoutType
        }
    }
}

extension BottomSheetPresentationAnimator {
    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from) else { return }
        fromVC.beginAppearanceTransition(false, animated: true)
        let presentable = panModalLayoutType(from: transitionContext)
        let yAnchor: CGFloat = presentable?.yAnchor ?? 0.0
        let panView: UIView = transitionContext.containerView.panContainerView ?? toVC.view
        panView.frame = transitionContext.finalFrame(for: toVC)
        panView.frame.origin.y = transitionContext.containerView.frame.height

        BottomSheetAnimator.animate {
            panView.frame.origin.y = yAnchor
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }

    }

    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
                  let fromVC = transitionContext.viewController(forKey: .from) else { return }
        toVC.beginAppearanceTransition(true, animated: true)
        let panView: UIView = transitionContext.containerView.panContainerView ?? fromVC.view

        BottomSheetAnimator.animate {
            panView.frame.origin.y = transitionContext.containerView.frame.height
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }

    }
}

extension BottomSheetPresentationAnimator {
    enum TransitionStyle {
        case presentation
        case dismissal
    }
}

//
//  BottomSheetTransition.swift
//  GouGouLiu
//
//  Created by HarryCao on 2024/6/12.
//

import UIKit

final class BottomSheetTransition: NSObject {
    private weak var presentedViewController: UIViewController?
    private let interactionController = BottomSheetInteractionController()
    private lazy var dimmingView: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black.withAlphaComponent(0.1)
        button.addTarget(self, action: #selector(dismissPresentedViewController), for: .touchUpInside)
        return button
    }()

    @objc private func dismissPresentedViewController() {
        presentedViewController?.dismiss(animated: true)
    }
}

extension BottomSheetTransition: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presentedViewController = presented
        interactionController.addGesture(presented)
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting, dimmingView: dimmingView)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        BottomSheetPresentAnimator(dimmingView: dimmingView)
    }

    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        BottomSheetDismissAnimator(dimmingView: dimmingView)
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController.interactionInProgress ? interactionController : nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController.interactionInProgress ? interactionController : nil
    }
}

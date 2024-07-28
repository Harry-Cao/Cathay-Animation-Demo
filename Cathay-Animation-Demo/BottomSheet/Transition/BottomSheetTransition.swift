//
//  BottomSheetTransition.swift
//  GouGouLiu
//
//  Created by HarryCao on 2024/6/12.
//

import UIKit

final class BottomSheetTransition: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return BottomSheetPresentationAnimator(transitionStyle: .presentation)
    }

    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return BottomSheetPresentationAnimator(transitionStyle: .dismissal)
    }
}

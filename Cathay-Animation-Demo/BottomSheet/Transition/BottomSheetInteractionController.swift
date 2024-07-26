//
//  BottomSheetInteractionController.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/26.
//

import UIKit

final class BottomSheetInteractionController: UIPercentDrivenInteractiveTransition {
    private(set) var interactionInProgress = false
    private weak var viewController: BottomSheetViewController?

    func addGesture(_ viewController: UIViewController) {
        guard let vc = viewController as? BottomSheetViewController else { return }
        self.viewController = vc
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        vc.container.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let transitionY = recognizer.translation(in: viewController?.view).y
        var progress = transitionY / (viewController?.view.bounds.height ?? 0.0)
        progress = min(max(progress, 0.0), 1.0)
        switch recognizer.state {
        case .began:
            interactionInProgress = true
            viewController?.dismiss(animated: true)
        case .changed:
            update(progress)
        case .ended:
            interactionInProgress = false
            if progress > 0.3 {
                finish()
            } else {
                cancel()
            }
        case .cancelled:
            interactionInProgress = false
            cancel()
        default:
            break
        }
    }
}

//
//  BottomSheetPresentationController.swift
//  GouGouLiu
//
//  Created by HarryCao on 2024/6/12.
//

import UIKit

final class BottomSheetPresentationController: UIPresentationController {
    private lazy var dimmingView: UIButton = {
        let button = UIButton()
        button.alpha = 0
        button.backgroundColor = .black.withAlphaComponent(0.1)
        button.addTarget(self, action: #selector(dismissPresentedViewController), for: .touchUpInside)
        return button
    }()
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPanOnPresentedView(_ :)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
//        gesture.delegate = self
        return gesture
    }()
    private lazy var panContainerView: PanContainerView = {
        let frame = containerView?.frame ?? .zero
        return PanContainerView(presentedView: presentedViewController.view, frame: frame)
    }()

    override var presentedView: UIView {
        return panContainerView
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)
        containerView.addGestureRecognizer(panGestureRecognizer)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 1
            self?.presentedViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0
            self?.presentingViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }

    @objc private func dismissPresentedViewController() {
        presentedViewController.dismiss(animated: true)
    }
}

extension BottomSheetPresentationController {
    @objc func didPanOnPresentedView(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            let yDisplacement = recognizer.translation(in: presentedView).y
            let targetY = presentedView.frame.origin.y + yDisplacement
            if targetY > BottomSheetConstrants.contentHeight {
                presentedView.frame.origin.y = presentedView.frame.origin.y + yDisplacement
            }
            recognizer.setTranslation(.zero, in: presentedView)
        default:
            let velocity = recognizer.velocity(in: presentedView)
            if velocity.y > 1000 {
                presentedViewController.dismiss(animated: true)
            } else {
                if presentedView.frame.minY > BottomSheetConstrants.contentHeight * 3 / 2 {
                    presentedViewController.dismiss(animated: true)
                } else {
                    UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0,
                                   options: [.allowUserInteraction, .beginFromCurrentState],
                                   animations: {
                        self.presentedView.frame.origin.y = BottomSheetConstrants.contentHeight
                    })
                }
            }
        }
    }
}

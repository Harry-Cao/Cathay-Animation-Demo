//
//  BottomSheetPresentationController.swift
//  GouGouLiu
//
//  Created by HarryCao on 2024/6/12.
//

import UIKit

final class BottomSheetPresentationController: UIPresentationController {
    private var isPresentedViewAnimating = false
    private var scrollObserver: NSKeyValueObservation?
    private var scrollViewYOffset: CGFloat = 0.0
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
        gesture.delegate = self
        return gesture
    }()
    private lazy var panContainerView: PanContainerView = {
        let frame = containerView?.frame ?? .zero
        return PanContainerView(presentedView: presentedViewController.view, frame: frame)
    }()
    private var presentable: BottomSheetPresentable? {
        return presentedViewController as? BottomSheetPresentable
    }
    private var isPresentedViewAnchored: Bool {
        if !isPresentedViewAnimating
            && presentedView.frame.minY.rounded() <= BottomSheetConstrants.expandY.rounded() {
            return true
        }
        return false
    }

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
        if let scrollView = presentable?.panScrollable {
            trackScrolling(scrollView)
            observe(scrollView: scrollView)
        }
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

// MARK: - Pan Gesture
extension BottomSheetPresentationController {
    @objc func didPanOnPresentedView(_ recognizer: UIPanGestureRecognizer) {
        guard shouldRespond(to: recognizer) else {
            recognizer.setTranslation(.zero, in: recognizer.view)
            return
        }
        switch recognizer.state {
        case .began, .changed:
            let yDisplacement = recognizer.translation(in: presentedView).y
            let targetY = presentedView.frame.origin.y + yDisplacement
            // Only support panning down
            if targetY > BottomSheetConstrants.expandY {
                adjust(toYPosition: presentedView.frame.origin.y + yDisplacement)
            }
            recognizer.setTranslation(.zero, in: presentedView)
        default:
            let velocity = recognizer.velocity(in: presentedView)
            if velocity.y > 1000 {
                presentedViewController.dismiss(animated: true)
            } else {
                if presentedView.frame.minY > BottomSheetConstrants.expandY * 3 / 2 {
                    presentedViewController.dismiss(animated: true)
                } else {
                    snap(toYPosition: BottomSheetConstrants.expandY)
                }
            }
        }
    }

    private func shouldRespond(to panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return !shouldFail(panGestureRecognizer: panGestureRecognizer)
    }

    private func shouldFail(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard isPresentedViewAnchored,
              let scrollView = presentable?.panScrollable,
              scrollView.contentOffset.y > 0 else {
            return false
        }
        let loc = panGestureRecognizer.location(in: presentedView)
        return (scrollView.frame.contains(loc) || scrollView.isScrolling)
    }

    func snap(toYPosition yPos: CGFloat) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: { [weak self] in
            self?.adjust(toYPosition: yPos)
            self?.isPresentedViewAnimating = true
        }) { [weak self] complete in
            self?.isPresentedViewAnimating = !complete
        }
    }

    private func adjust(toYPosition yPos: CGFloat) {
        presentedView.frame.origin.y = yPos
        let yDisplacement = yPos - BottomSheetConstrants.expandY
        dimmingView.alpha = 1 - (yDisplacement / presentedView.frame.height)
    }
}

extension BottomSheetPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollView Observer
extension BottomSheetPresentationController {
    func observe(scrollView: UIScrollView?) {
        scrollObserver?.invalidate()
        scrollObserver = scrollView?.observe(\.contentOffset, options: .old) { [weak self] scrollView, change in
            guard self?.containerView != nil else { return }
            self?.didPanOnScrollView(scrollView, change: change)
        }
    }

    func didPanOnScrollView(_ scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        guard !presentedViewController.isBeingDismissed,
              !presentedViewController.isBeingPresented else { return }
        if scrollView.isScrolling && !isPresentedViewAnchored {
            haltScrolling(scrollView)
        } else if scrollView.contentOffset.y <= 0 {
            handleScrollViewTopBounce(scrollView: scrollView, change: change)
        } else {
            trackScrolling(scrollView)
        }
    }

    func haltScrolling(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollViewYOffset), animated: false)
    }

    func trackScrolling(_ scrollView: UIScrollView) {
        scrollViewYOffset = max(scrollView.contentOffset.y, 0)
    }

    func handleScrollViewTopBounce(scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        guard let oldYValue = change.oldValue?.y, scrollView.isDecelerating
            else { return }
        let yOffset = scrollView.contentOffset.y
        let presentedSize = containerView?.frame.size ?? .zero
        presentedView.bounds.size = CGSize(width: presentedSize.width, height: presentedSize.height + yOffset)
        if oldYValue > yOffset {
            presentedView.frame.origin.y = BottomSheetConstrants.expandY - yOffset
        } else {
            scrollViewYOffset = 0
            snap(toYPosition: BottomSheetConstrants.expandY)
        }
    }
}

// MARK: - UIScrollView extension
private extension UIScrollView {
    var isScrolling: Bool {
        return isDragging && !isDecelerating || isTracking
    }
}

//
//  FlightCardMainScrollView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/8/19.
//

import UIKit

protocol FlightCardMainScrollViewGestureDelegate: AnyObject {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

final class FlightCardMainScrollView: UIScrollView, UIGestureRecognizerDelegate {
    weak var gestureDelegate: FlightCardMainScrollViewGestureDelegate?

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureDelegate?.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
    }
}

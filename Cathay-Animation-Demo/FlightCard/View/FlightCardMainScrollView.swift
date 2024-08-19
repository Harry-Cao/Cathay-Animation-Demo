//
//  FlightCardMainScrollView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/8/19.
//

import UIKit

final class FlightCardMainScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

//
//  ScrollViewTracker.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/2.
//

import UIKit

protocol ScrollViewTrackerDelegate: AnyObject {
    func tracker(_ tracker: ScrollViewTracker, onScroll process: CGFloat)
}

class ScrollViewTracker {
    weak var delegate: ScrollViewTrackerDelegate?
    private var direction: TrackDirection = .up
    private var startOffset: CGFloat = 0.0
    private var endOffset: CGFloat = 0.0
    private var factor: CGFloat = 1.0

    func setTransform(startOffset: CGFloat, endOffset: CGFloat, factor: CGFloat = 1.0) {
        self.direction = endOffset < startOffset ? .down : .up
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.factor = factor
    }

    func trackScrollView(_ scrollView: UIScrollView) {
        let process = process(from: scrollView.contentOffset.y)
        delegate?.tracker(self, onScroll: process)
    }

    func process(from offsetY: CGFloat) -> CGFloat {
        var process: CGFloat = 0.0
        switch direction {
        case .up:
            process = (offsetY - startOffset) * factor / abs(endOffset - startOffset)
        case .down:
            process = (startOffset - offsetY) * factor / abs(endOffset - startOffset)
        }
        return max(0, min(process, 1))
    }
}

extension ScrollViewTracker {
    enum TrackDirection {
        case up
        case down
    }
}

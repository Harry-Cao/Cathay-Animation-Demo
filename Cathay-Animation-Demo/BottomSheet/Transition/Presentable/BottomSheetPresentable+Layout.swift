//
//  BottomSheetPresentable+Layout.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/8/1.
//

import UIKit

extension BottomSheetPresentable where Self: UIViewController {
    typealias LayoutType = UIViewController & BottomSheetPresentable

    var presentedVC: BottomSheetPresentationController? {
        return presentationController as? BottomSheetPresentationController
    }

    var bottomYPos: CGFloat {
        guard let container = presentedVC?.containerView else { return view.bounds.height }
        return container.bounds.size.height
    }

    func topMargin(from height: CGFloat) -> CGFloat {
        return bottomYPos - height
    }

    var yAnchor: CGFloat {
        return topMargin(from: contentHeight)
    }
}

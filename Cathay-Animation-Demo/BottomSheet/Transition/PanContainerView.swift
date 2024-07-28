//
//  PanContainerView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/29.
//

import UIKit

final class PanContainerView: UIView {
    init(presentedView: UIView, frame: CGRect) {
        super.init(frame: frame)
        addSubview(presentedView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    var panContainerView: PanContainerView? {
        return subviews.first(where: { view -> Bool in
            view is PanContainerView
        }) as? PanContainerView
    }
}

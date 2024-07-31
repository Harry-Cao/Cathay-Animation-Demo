//
//  BottomSheetAnimator.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/8/1.
//

import UIKit

struct BottomSheetAnimator {
    static func animate(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: animations,
                       completion: completion)
    }
}

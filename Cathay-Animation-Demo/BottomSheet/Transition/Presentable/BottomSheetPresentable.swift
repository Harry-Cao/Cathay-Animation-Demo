//
//  BottomSheetPresentable.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/31.
//

import UIKit

protocol BottomSheetPresentable: AnyObject {
    var contentHeight: CGFloat { get }
    var panScrollable: UIScrollView? { get }
    var topBounceAlign: Bool { get }
}

extension BottomSheetPresentable {
    var panScrollable: UIScrollView? { nil }
    var topBounceAlign: Bool { false }
}

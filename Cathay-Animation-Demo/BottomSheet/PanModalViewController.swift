//
//  PanModalViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/27.
//

import UIKit
import SnapKit
import PanModal

class PanModalViewController: UIViewController {

    private(set) var container: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        [container].forEach(view.addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension PanModalViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(400)
    }
    var showDragIndicator: Bool {
        return false
    }
    var anchorModalToLongForm: Bool {
        return false
    }
    var isHapticFeedbackEnabled: Bool {
        return false
    }
    var panModalBackgroundColor: UIColor {
        return .black.withAlphaComponent(0.1)
    }
}

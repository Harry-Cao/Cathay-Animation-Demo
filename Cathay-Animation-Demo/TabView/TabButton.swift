//
//  TabButton.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/30.
//

import UIKit
import SnapKit

class TabButton: UIView {
    private let maskButton = UIButton()
    private let onTap: ButtonTapBlock

    init(view: UIView, onTap: @escaping ButtonTapBlock) {
        self.onTap = onTap
        super.init(frame: .zero)
        [view, maskButton].forEach(addSubview)
        view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.center.equalToSuperview()
        }
        maskButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        maskButton.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onTapButton() {
        onTap()
    }
}

extension TabButton {
    typealias ButtonTapBlock = () -> Void
}

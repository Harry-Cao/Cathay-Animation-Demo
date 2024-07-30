//
//  TabItem.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/30.
//

import UIKit
import SnapKit

class TabItem: UIView {
    private let maskButton = UIButton()
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    private let onTapBlock: ButtonTapBlock

    init(onTap: @escaping ButtonTapBlock) {
        self.onTapBlock = onTap
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [label, maskButton].forEach(addSubview)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.center.equalToSuperview()
        }
        maskButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        maskButton.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
    }

    func setup(model: TabModel) {
        self.label.text = model.title
    }

    func setHighlight(_ highlight: Bool) {
        self.backgroundColor = highlight ? .green : .clear
    }

    @objc private func onTapButton() {
        onTapBlock()
    }
}

extension TabItem {
    typealias ButtonTapBlock = () -> Void
}

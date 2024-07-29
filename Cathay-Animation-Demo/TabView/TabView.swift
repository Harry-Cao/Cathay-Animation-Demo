//
//  TabView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit
import SnapKit

class TabView: UIView {
    private var dataSource: [TabItem] = [
        TabItem(title: "1")
    ]
    private lazy var tabContainer: UIScrollView = {
        let view = UIScrollView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [tabContainer].forEach(addSubview)
        tabContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

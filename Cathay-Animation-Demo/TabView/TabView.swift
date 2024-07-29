//
//  TabView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit
import SnapKit

class TabView: UIView {
    static let height: CGFloat = 68.0
    private(set) var currentIndex: Int = 0
    private let spacing: CGFloat = 20.0
    private var dataSource: [TabItem] = [
        TabItem(title: "00001"),
        TabItem(title: "00002"),
        TabItem(title: "00003"),
        TabItem(title: "00004"),
        TabItem(title: "00005"),
        TabItem(title: "00006"),
        TabItem(title: "00007"),
    ]
    private let tabScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private let tabContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        return view
    }()
    private lazy var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        setupUI()
        reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        tabContainer.spacing = spacing
        addSubview(tabScrollView)
        [tabContainer, indicator].forEach(tabScrollView.addSubview)
        tabScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tabContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(spacing)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(TabView.height)
            make.width.greaterThanOrEqualTo(tabScrollView).offset(-2*spacing)
        }
    }

    func reloadData() {
        tabContainer.arrangedSubviews.forEach {
            tabContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        dataSource.forEach {
            let label = UILabel()
            label.text = $0.title
            label.textAlignment = .center
            label.backgroundColor = .green
            tabContainer.addArrangedSubview(label)
        }
    }

    func select(index: Int) {
        currentIndex = index
        // TODO: - Animation
    }
}

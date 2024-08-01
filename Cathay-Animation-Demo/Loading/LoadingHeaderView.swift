//
//  LoadingHeaderView.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/1.
//

import UIKit
import SnapKit

class LoadingHeaderView: UIView {
    static let height: CGFloat = 200 + TabView.height
    private let animationView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        return imageView
    }()
    lazy var dateBar: TabView = {
        let tabView = TabView()
        tabView.delegate = self
        return tabView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [animationView, dateBar].forEach(addSubview)
        dateBar.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(TabView.height)
        }
    }

    func setState(_ state: HeaderState) {
        switch state {
        case .loading:
            animationView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        case .sticky(let process):
            animationView.frame.size.height = 200
            animationView.layer.masksToBounds = true
            animationView.layer.cornerRadius = 40
            animationView.layer.maskedCorners = [.layerMinXMaxYCorner]
        }
    }
}

extension LoadingHeaderView: TabViewDelegate {
    func tabView(_ tabView: TabView, didSelect toIndex: Int, fromIndex: Int) {
        print("!!!didSelect toIndex: \(toIndex), fromIndex: \(fromIndex)")
    }
}

extension LoadingHeaderView {
    enum HeaderState {
        case loading
        case sticky(process: CGFloat)
    }
}

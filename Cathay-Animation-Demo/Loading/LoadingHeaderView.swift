//
//  LoadingHeaderView.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/1.
//

import UIKit
import SnapKit

class LoadingHeaderView: UIView {
    static let height: CGFloat = LoadingAnimationView.height + TabView.height
    let animationView = LoadingAnimationView()
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
        backgroundColor = .systemBackground
        [animationView, dateBar].forEach(addSubview)
        animationView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height)
        }
        dateBar.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(TabView.height)
        }
    }

    func setState(_ state: HeaderState) {
        switch state {
        case .loading:
            animationView.snp.updateConstraints { make in
                make.height.equalTo(UIScreen.main.bounds.height)
            }
        case .normal:
            animationView.snp.updateConstraints { make in
                make.height.equalTo(LoadingAnimationView.height)
            }
            animationView.layer.masksToBounds = true
            animationView.layer.cornerRadius = 40
            animationView.layer.maskedCorners = [.layerMinXMaxYCorner]
            layoutIfNeeded()
        }
    }

    func trackScrollView(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            animationView.snp.updateConstraints { make in
                make.height.equalTo(LoadingAnimationView.height - offsetY)
            }
        } else {
            let displacementY = offsetY / 3
            let height = max(LoadingAnimationView.minimumHeight, LoadingAnimationView.height - displacementY)
            animationView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
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
        case normal
    }
}

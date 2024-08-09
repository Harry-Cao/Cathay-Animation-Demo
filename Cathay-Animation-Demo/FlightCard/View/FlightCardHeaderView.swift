//
//  FlightCardHeaderView.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/1.
//

import UIKit
import SnapKit

class FlightCardHeaderView: UIView {
    static let height: CGFloat = FlightCardAnimationView.height + TabView.height
    let animationView = FlightCardAnimationView()
    lazy var dateBar = TabView()

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
                make.height.equalTo(FlightCardAnimationView.height)
            }
            animationView.layer.masksToBounds = true
            animationView.layer.cornerRadius = 40
            animationView.layer.maskedCorners = [.layerMinXMaxYCorner]
            layoutIfNeeded()
        }
    }

    func updateExtraHeight(_ height: CGFloat) {
        animationView.snp.updateConstraints { make in
            make.height.equalTo(FlightCardAnimationView.height + height)
        }
    }

    func updateDismissProcess(_ process: CGFloat, minimumHeight: CGFloat) {
        let displacementY = (FlightCardAnimationView.height - minimumHeight) * process
        let height = FlightCardAnimationView.height - displacementY
        animationView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        animationView.updateDismissProcess(process)
    }
}

extension FlightCardHeaderView {
    enum HeaderState {
        case loading
        case normal
    }
}

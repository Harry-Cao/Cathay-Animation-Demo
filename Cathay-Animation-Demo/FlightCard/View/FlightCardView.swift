//
//  FlightCardView.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/14.
//

import UIKit
import SnapKit

class FlightCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .blue
        layer.masksToBounds = true
        layer.cornerRadius = 12
    }
}

//
//  FlightCardTableViewCell.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit
import SnapKit

class FlightCardTableViewCell: UITableViewCell {
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [container].forEach(contentView.addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }

    func setup(finishLoading: Bool) {
        if finishLoading {
            container.alpha = 1
        } else {
            container.alpha = 0
        }
    }

    func fadeIn() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            container.alpha = 1
        }
    }
}

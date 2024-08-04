//
//  LoadingTableViewCell.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit
import SnapKit

class LoadingTableViewCell: UITableViewCell {
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(container)
        [label].forEach(container.addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func setup(flightModel: FlightModel, finishLoading: Bool) {
        container.alpha = finishLoading ? 1 : 0
        label.text = String(flightModel.id)
    }

    func fadeIn() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            container.alpha = 1
        }
    }
}

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
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.frame = CGRect(x: 20, y: 20, width: contentView.bounds.width - 40, height: contentView.bounds.height - 40)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        container.alpha = 1
    }

    func setup(flightModel: FlightCardModel, finishLoading: Bool) {
        container.alpha = finishLoading ? 1 : 0
        label.text = String(flightModel.id)
    }
}

// MARK: - Animation
extension FlightCardTableViewCell {
    func fadeIn(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            container.alpha = 1
        } completion: { _ in
            completion()
        }
    }

    func prepareFlyIn(offset: CGFloat) {
        container.layer.removeAllAnimations()
        container.frame.origin.x = 20 + offset
        layoutIfNeeded()
    }

    func flyIn(duration: TimeInterval, completion: @escaping () -> Void) {
        container.layer.removeAllAnimations()
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            container.frame.origin.x = 20
        } completion: { _ in
            completion()
        }
    }
}

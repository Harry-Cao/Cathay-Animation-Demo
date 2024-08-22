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
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    private let label = UILabel()
    private var finishLoading: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(container)
        [label].forEach(container.addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        container.alpha = 1
    }

    func setup(flightModel: FlightCardModel, finishLoading: Bool) {
        self.finishLoading = finishLoading
        container.alpha = finishLoading ? 1 : 0
        label.text = String(flightModel.id)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard finishLoading else { return }
        if highlighted {
            UIView.animate(withDuration: 0.2) {
                self.container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.container.alpha = 0.5
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.container.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.container.alpha = 1
            }
        }
    }
}

// MARK: - Animation
extension FlightCardTableViewCell {
    func fadeIn(delay: TimeInterval, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                self.container.alpha = 1
            } completion: { _ in
                completion()
                self.finishLoading = true
            }
        }
    }

    func prepareFlyIn(offset: CGFloat) {
        container.layer.removeAllAnimations()
        container.transform = CGAffineTransform(translationX: offset, y: .zero)
        layoutIfNeeded()
    }

    func flyIn(duration: TimeInterval, completion: @escaping () -> Void) {
        container.layer.removeAllAnimations()
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            container.transform = CGAffineTransform(translationX: .zero, y: .zero)
        } completion: { _ in
            completion()
        }
    }
}

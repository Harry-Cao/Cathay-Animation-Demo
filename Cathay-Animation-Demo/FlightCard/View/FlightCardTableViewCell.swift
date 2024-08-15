//
//  FlightCardTableViewCell.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit
import SnapKit

class FlightCardTableViewCell: UITableViewCell {
    static let height: CGFloat = 100.0
    private var currentModel: FlightCardModel?
    private var showingCard = FlightCardView()
    private var standByCard = FlightCardView()
    private var cards: [FlightCardView] { [showingCard, standByCard] }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [showingCard, standByCard].forEach(contentView.addSubview)
        showingCard.snp.makeConstraints { make in
            make.size.equalToSuperview().inset(20)
            make.centerX.centerY.equalToSuperview()
        }
        standByCard.snp.makeConstraints { make in
            make.size.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(UIScreen.main.bounds.width)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cards.forEach { $0.alpha = 0 }
    }

    func setup(model: FlightCardModel?, finishLoading: Bool) {
        currentModel = model
        if !finishLoading || model == nil {
            cards.forEach { $0.alpha = 0 }
        } else {
            cards.forEach { $0.alpha = 1 }
        }
    }
}

// MARK: - Animations
extension FlightCardTableViewCell {
    func fadeIn(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            cards.forEach { $0.alpha = 1 }
        } completion: { _ in
            completion()
        }
    }

    func switchTo(model toModel: FlightCardModel?,
                  direction: SwitchDirection,
                  extraDuration: TimeInterval,
                  completion: @escaping () -> Void)
    {
        let offsetX = direction == .left ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width
        // handle out
        UIView.animate(withDuration: 0.3) { [self] in
            showingCard.snp.updateConstraints { make in
                make.centerX.equalToSuperview().offset(offsetX)
            }
            layoutIfNeeded()
        }
        // handle in
        standByCard.snp.updateConstraints { make in
            make.centerX.equalToSuperview().offset(-offsetX)
        }
        layoutIfNeeded()
        standByCard.alpha = toModel == nil ? 0 : 1
        UIView.animate(withDuration: 0.3 + extraDuration, animations: { [self] in
            standByCard.snp.updateConstraints { make in
                make.centerX.equalToSuperview()
            }
            layoutIfNeeded()
        }) { [self] _ in
            // exchange these cards
            (showingCard, standByCard) = (standByCard, showingCard)
            completion()
        }
    }
}

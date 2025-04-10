//
//  TabView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit
import SnapKit

class TabView: UIView {
    weak var delegate: TabViewDelegate?
    static let height: CGFloat = 68.0
    private(set) var currentIndex: Int = -1
    private let spacing: CGFloat = 0.0
    private let indicatorShortenWidth: CGFloat = 40.0
    private let indicatorHeight: CGFloat = 2.0
    private let animationDuration: TimeInterval = 0.5
    private var dataSource: [TabModel] = [
        TabModel.loading,
        TabModel.loading,
        TabModel.loading,
        TabModel.loading,
        TabModel.loading,
        TabModel.loading,
        TabModel.loading,
    ]
    private lazy var tabScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        return view
    }()
    private let tabStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        return view
    }()
    private lazy var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = indicatorHeight / 2
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        setupUI()
        refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        tabStackView.spacing = spacing
        addSubview(tabScrollView)
        [tabStackView, indicator].forEach(tabScrollView.addSubview)
        tabScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tabStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(spacing)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(TabView.height)
            make.width.greaterThanOrEqualTo(tabScrollView).offset(-2*spacing)
        }
        indicator.frame = CGRect(x: 0, y: TabView.height - indicatorHeight, width: 0, height: indicatorHeight)
    }

    func setTabs(_ tabs: [TabModel]) {
        dataSource = tabs
        refresh()
    }

    private func refresh() {
        tabStackView.arrangedSubviews.forEach {
            tabStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        dataSource.enumerated().forEach { (index, model) in
            let button = TabItem { [weak self] in
                self?.select(index: index)
            }
            button.setup(model: model)
            tabStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalToSuperview()
            }
        }
        layoutIfNeeded()
    }

    func select(index: Int) {
        guard !tabStackView.arrangedSubviews.isEmpty,
              (0...tabStackView.arrangedSubviews.count-1).contains(index) else { return }
        delegate?.tabView(self, didSelect: index, fromIndex: currentIndex)
        setHighlight(index: index)
        animateTo(index: index)
        currentIndex = index
    }

    private func setHighlight(index: Int) {
        tabStackView.arrangedSubviews.enumerated().forEach { (itemIndex, item) in
            guard let buttonItem = item as? TabItem else { return }
            buttonItem.setHighlight(itemIndex == index)
        }
    }
}

// MARK: - Auto-Focus
extension TabView: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate,
              let nearestIndex = indexNearestCenter else { return }
        select(index: nearestIndex)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let nearestIndex = indexNearestCenter else { return }
        select(index: nearestIndex)
    }

    private var indexNearestCenter: Int? {
        var closestIndex: Int?
        var minimumDistance = CGFloat.greatestFiniteMagnitude
        let centerX: CGFloat = self.frame.width / 2
        tabStackView.arrangedSubviews.enumerated().forEach { (index, item) in
            let midX = item.convert(item.bounds, to: self).midX
            let distance = abs(midX - centerX)
            if distance < minimumDistance {
                minimumDistance = distance
                closestIndex = index
            }
        }
        return closestIndex
    }
}

// MARK: - Animation
extension TabView {
    private func animateTo(index: Int) {
        indicator.layer.removeAllAnimations()
        let toItem = tabStackView.arrangedSubviews[index]
        let toItemRect = toItem.convert(toItem.bounds, to: tabScrollView)
        let singleAnimationDuration: TimeInterval = animationDuration / 2

        if currentIndex == -1 {
            indicator.frame.origin.x = toItemRect.minX + (toItemRect.width - indicatorShortenWidth) / 2
            indicator.frame.size.width = indicatorShortenWidth
            UIView.animate(withDuration: singleAnimationDuration, delay: 0, options: .curveEaseOut) { [weak self] in
                guard let self = self else { return }
                indicator.frame.origin.x = toItemRect.minX
                indicator.frame.size.width = toItemRect.width
            }
            layoutIfNeeded()
            return
        }

        let shortenMoveAnimator = UIViewPropertyAnimator(duration: singleAnimationDuration, curve: .easeInOut) { [weak self] in
            guard let self = self else { return }
            updateContentOffset(index: index)
            indicator.frame.origin.x = toItemRect.minX + (toItemRect.width - indicatorShortenWidth) / 2
            indicator.frame.size.width = indicatorShortenWidth
        }
        let elongateAnimator = UIViewPropertyAnimator(duration: singleAnimationDuration, curve: .easeOut) { [weak self] in
            guard let self = self else { return }
            indicator.frame.origin.x = toItemRect.minX
            indicator.frame.size.width = toItemRect.width
        }
        shortenMoveAnimator.addCompletion { _ in
            elongateAnimator.startAnimation()
        }
        shortenMoveAnimator.startAnimation()
    }

    private func updateContentOffset(index: Int) {
        let item = tabStackView.arrangedSubviews[index]
        let itemRect = item.convert(item.bounds, to: self)
        let horizontalOffsetX = horizontalOffsetToMiddle(rect: itemRect, to: self)
        let targetOffsetX = tabScrollView.contentOffset.x + horizontalOffsetX
        let contentOffsetX = max(0, min(targetOffsetX, tabScrollView.contentSize.width - self.frame.width))
        tabScrollView.contentOffset.x = contentOffsetX
    }

    private func horizontalOffsetToMiddle(rect: CGRect, to view: UIView) -> CGFloat {
        let middleX = (view.frame.width - rect.width) / 2
        return rect.minX - middleX
    }
}

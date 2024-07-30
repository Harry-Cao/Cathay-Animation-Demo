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
    private let spacing: CGFloat = 20.0
    private let indicatorDefaultWidth: CGFloat = 40.0
    private let indicatorHeight: CGFloat = 2.0
    private var dataSource: [TabItem] = [
        TabItem(title: "Tab1 Title"),
        TabItem(title: "Tab2 Title"),
        TabItem(title: "Tab3 Title"),
        TabItem(title: "Tab4 Title"),
        TabItem(title: "Tab5 Title"),
        TabItem(title: "Tab6 Title"),
        TabItem(title: "Tab7 Title"),
    ]
    private let tabScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
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
        view.layer.cornerRadius = 2
        return view
    }()
    private lazy var animationDuration: TimeInterval = {
        return delegate?.animationDuration ?? 0.3
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
        indicator.frame = CGRect(x: 0, y: TabView.height - indicatorHeight, width: indicatorDefaultWidth, height: indicatorHeight)
    }

    func refresh() {
        tabStackView.arrangedSubviews.forEach {
            tabStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        dataSource.enumerated().forEach { (index, item) in
            let label = UILabel()
            label.text = item.title
            label.textAlignment = .center
            let button = TabButton(view: label) { [weak self] in
                self?.select(index: index)
            }
            button.backgroundColor = .green
            tabStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalToSuperview()
            }
        }
    }

    func select(index: Int) {
        guard (0...tabStackView.arrangedSubviews.count-1).contains(index) else { return }
        delegate?.tabView(self, didSelect: index, fromIndex: currentIndex)
        tabViewAnimateTo(index: index)
        indicatorAnimateTo(index: index)
        currentIndex = index
    }
}

// MARK: - Animation
extension TabView {
    private func tabViewAnimateTo(index: Int) {
        let item = tabStackView.arrangedSubviews[index]
        let itemRect = item.convert(item.bounds, to: self)
        let horizontalOffset = horizontalOffsetToMiddle(rect: itemRect, to: self)
        let targetOffsetX = tabScrollView.contentOffset.x + horizontalOffset
        let contentOffsetX = max(0, min(targetOffsetX, tabScrollView.contentSize.width - self.frame.width))

        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) { [self] in
            tabScrollView.contentOffset.x = contentOffsetX
        }
    }

    private func horizontalOffsetToMiddle(rect: CGRect, to view: UIView) -> CGFloat {
        let middleX = (view.frame.width - rect.width) / 2
        return rect.minX - middleX
    }

    private func indicatorAnimateTo(index: Int) {
        let toItem = tabStackView.arrangedSubviews[index]
        let toItemRect = toItem.convert(toItem.bounds, to: tabScrollView)

        if currentIndex == -1 {
            indicator.frame.origin.x = toItemRect.minX + (toItemRect.width - indicatorDefaultWidth) / 2
            indicator.frame.size.width = indicatorDefaultWidth
            UIView.animate(withDuration: animationDuration) { [self] in
                indicator.frame.origin.x = toItemRect.minX
                indicator.frame.size.width = toItemRect.width
            }
            return
        }

        guard (0...tabStackView.arrangedSubviews.count-1).contains(currentIndex) else { return }
        let currentItem = tabStackView.arrangedSubviews[currentIndex]
        let currentItemRect = currentItem.convert(currentItem.bounds, to: tabScrollView)

        let shortenAnimator = UIViewPropertyAnimator(duration: animationDuration / 3, curve: .linear) { [self] in
            indicator.frame.origin.x = currentItemRect.minX + (currentItemRect.width - indicatorDefaultWidth) / 2
            indicator.frame.size.width = indicatorDefaultWidth
        }
        let moveAnimator = UIViewPropertyAnimator(duration: animationDuration / 3, curve: .linear) { [self] in
            indicator.frame.origin.x = toItemRect.minX + (toItemRect.width - indicatorDefaultWidth) / 2
        }
        let elongateAnimator = UIViewPropertyAnimator(duration: animationDuration / 3, curve: .linear) { [self] in
            indicator.frame.origin.x = toItemRect.minX
            indicator.frame.size.width = toItemRect.width
        }
        shortenAnimator.addCompletion { _ in
            moveAnimator.startAnimation()
        }
        moveAnimator.addCompletion { _ in
            elongateAnimator.startAnimation()
        }
        shortenAnimator.startAnimation()
    }
}

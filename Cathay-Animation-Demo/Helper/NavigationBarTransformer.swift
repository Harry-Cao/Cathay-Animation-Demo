//
//  NavigationBarTransformer.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/26.
//

import UIKit

protocol NavigationBarTransformerDelegate: AnyObject {
    func transformerTargetNavigationBar() -> UINavigationBar?
}

final class NavigationBarTransformer {
    weak var delegate: NavigationBarTransformerDelegate?
    private var startOffset: CGFloat = 0.0
    private var endOffset: CGFloat = 100.0
    private lazy var navigationBar: UINavigationBar? = {
        return delegate?.transformerTargetNavigationBar()
    }()

    func setTransform(startOffset: CGFloat, endOffset: CGFloat) {
        self.startOffset = startOffset
        let end = max(startOffset, endOffset)
        self.endOffset = end
    }

    func trackScrollView(_ scrollView: UIScrollView) {
        var alpha: CGFloat = 0.0
        if scrollView.contentOffset.y > startOffset {
            alpha = (scrollView.contentOffset.y - startOffset) / (endOffset - startOffset)
        }
        updateNavigationBarAlpha(alpha)
    }

    func updateNavigationBarAlpha(_ alpha: CGFloat) {
        guard let navigationBar = navigationBar else { return }
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = .systemBackground.withAlphaComponent(alpha)
        navigationBar.standardAppearance = navigationBarAppearance
    }
}

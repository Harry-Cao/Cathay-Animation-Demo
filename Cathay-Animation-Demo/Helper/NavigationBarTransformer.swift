//
//  NavigationBarTransformer.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/26.
//

import UIKit

protocol NavigationBarTransformerDelegate: AnyObject {
    var transformerTargetNavigationBar: UINavigationBar? { get }
    var transformerFactor: CGFloat { get }
    func transformer(_ transformer: NavigationBarTransformer, displaying process: CGFloat)
}

extension NavigationBarTransformerDelegate {
    var transformerFactor: CGFloat { 1.0 }
    func transformer(_ transformer: NavigationBarTransformer, displaying process: CGFloat) {}
}

final class NavigationBarTransformer {
    weak var delegate: NavigationBarTransformerDelegate?
    private var startOffset: CGFloat = 0.0
    private var endOffset: CGFloat = 100.0

    func setTransform(startOffset: CGFloat, endOffset: CGFloat) {
        self.startOffset = startOffset
        let end = max(startOffset, endOffset)
        self.endOffset = end
    }

    func trackScrollView(_ scrollView: UIScrollView) {
        var process: CGFloat = 0.0
        let transformFactor = delegate?.transformerFactor ?? 1.0
        if scrollView.contentOffset.y > startOffset {
            process = (scrollView.contentOffset.y - startOffset) * transformFactor / (endOffset - startOffset)
        }
//        updateNavigationBarAlpha(process)
        delegate?.transformer(self, displaying: process)
    }

    func updateNavigationBarAlpha(_ alpha: CGFloat) {
        guard let navigationBar = delegate?.transformerTargetNavigationBar else { return }
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = .systemBackground.withAlphaComponent(alpha)
        navigationBar.standardAppearance = navigationBarAppearance
    }
}

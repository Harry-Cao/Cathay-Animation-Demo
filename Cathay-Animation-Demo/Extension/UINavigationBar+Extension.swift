//
//  UINavigationBar+Extension.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/2.
//

import UIKit

extension UINavigationBar {
    func setAlpha(_ alpha: CGFloat) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = .systemBackground.withAlphaComponent(alpha)
        self.standardAppearance = navigationBarAppearance
    }
}

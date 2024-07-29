//
//  LoadingTableViewCell.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.frame.size = CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
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
    }

    func setup(finishLoading: Bool) {
        if finishLoading {
            container.frame.origin = CGPoint(x: 20, y: 20)
        } else {
            container.frame.origin = CGPoint(x: UIScreen.main.bounds.width, y: 20)
        }
    }

    func fadeIn() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            container.frame.origin = CGPoint(x: 20, y: 20)
        }
    }
}

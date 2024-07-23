//
//  ResultTableViewCell.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/23.
//

import UIKit
import SnapKit

class ResultTableViewCell: UITableViewCell {
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
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
        container.alpha = 0
        container.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width - 40, height: 60)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        container.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 60)
        container.alpha = 1
    }

    func setup() {
        container.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 60)
        container.alpha = 1
    }

    func fadeIn() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.container.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 60)
            self.container.alpha = 1
        }
    }
}

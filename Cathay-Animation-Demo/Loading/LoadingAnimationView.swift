//
//  LoadingAnimationView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/8/1.
//

import UIKit
import SnapKit

class LoadingAnimationView: UIView {
    static let height: CGFloat = 200.0
    static let minimumHeight: CGFloat = 100.0

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    private let viewMask = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [container, viewMask].forEach(addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewMask.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateDismissProcess(_ process: CGFloat) {
        viewMask.backgroundColor = .white.withAlphaComponent(process)
    }
}

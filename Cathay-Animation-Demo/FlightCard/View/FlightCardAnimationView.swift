//
//  FlightCardAnimationView.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/8/1.
//

import UIKit
import SnapKit

protocol FlightCardAnimationViewDelegate: AnyObject {
    func didTapOnBackButton()
}

class FlightCardAnimationView: UIView {
    weak var delegate: FlightCardAnimationViewDelegate?
    static let height: CGFloat = 200.0

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    private let viewMask: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        return view
    }()
    lazy var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrowshape.turn.up.backward.fill")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.tintColor = .label
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [container, viewMask, backButton].forEach(addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewMask.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(44)
            make.leading.equalToSuperview().inset(10)
            make.size.equalTo(44)
        }
    }

    func updateDismissProcess(_ process: CGFloat) {
        viewMask.alpha = process
    }

    @objc private func didTapBackButton() {
        delegate?.didTapOnBackButton()
    }
}

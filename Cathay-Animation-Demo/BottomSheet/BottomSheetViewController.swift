//
//  BottomSheetViewController.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/26.
//

import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {

    private let backgroundButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black.withAlphaComponent(0.3)
        return button
    }()
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesture()
    }

    private func setupUI() {
        [backgroundButton, container].forEach(view.addSubview)
        backgroundButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(400)
        }
        backgroundButton.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
    }

    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        container.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            print("!!! BEGAN !!!")
        case .changed:
            let transitionY = recognizer.translation(in: container).y
            print("!!! CHANGED !!!, transitionY: \(transitionY)")
        case .ended, .cancelled:
            print("!!! ENDED | CANCEL !!!")
        default:
            break
        }
    }

    @objc private func onDismiss() {
        self.dismiss(animated: true)
    }

}

//
//  BottomSheetViewController.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/26.
//

import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {

    private let dismissButton = UIButton()
    private(set) var container: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        [dismissButton, container].forEach(view.addSubview)
        dismissButton.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(container.snp.top)
        }
        container.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(400)
        }
        dismissButton.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
    }

    @objc private func onDismiss() {
        self.dismiss(animated: true)
    }

}

//
//  BottomSheetViewController.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/26.
//

import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {

    private let backgroundButton = UIButton()
    private(set) var container: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

    @objc private func onDismiss() {
        self.dismiss(animated: true)
    }

}

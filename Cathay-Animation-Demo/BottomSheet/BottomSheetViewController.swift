//
//  BottomSheetViewController.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/26.
//

import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {
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
        [container].forEach(view.addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

//
//  ViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "Hi~"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let resultVC = ResultViewController()
//        resultVC.modalPresentationStyle = .formSheet
//        resultVC.sheetPresentationController?.detents = [.medium(), .large()]
//        resultVC.sheetPresentationController?.prefersGrabberVisible = true
        let naviVC = UINavigationController(rootViewController: resultVC)
        naviVC.modalPresentationStyle = .fullScreen
        self.present(naviVC, animated: true)
    }

}


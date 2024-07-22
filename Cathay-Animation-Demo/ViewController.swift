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
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .fullScreen
        self.present(loadingVC, animated: true)
        mockRequestData { [weak self] data in
            guard let self = self else { return }
            let resultVC = ResultViewController(dataSource: data)
            resultVC.modalPresentationStyle = .fullScreen
            resultVC.delegate = self
            loadingVC.present(resultVC, animated: true)
        }
    }

    private func mockRequestData(callBack: @escaping ([Int]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            var dataSource = [Int]()
            for i in 0...20 {
                dataSource.append(i)
            }
            callBack(dataSource)
        }
    }

}

extension ViewController: ResultViewControllerDelegate {
    func onDismiss() {
        self.dismiss(animated: true)
    }
}


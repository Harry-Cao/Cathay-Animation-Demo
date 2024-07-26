//
//  ViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private let dataSource: [DemoType] = DemoType.allCases
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        return tableView
    }()
    private let bottomSheetTransition = BottomSheetTransition()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = type.title
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = dataSource[indexPath.row]
        switch type {
        case .loading:
            let vc = ResultViewController()
            let naviVC = UINavigationController(rootViewController: vc)
            naviVC.modalPresentationStyle = .fullScreen
            self.present(naviVC, animated: true)
        case .bottomSheet:
            let vc = BottomSheetViewController()
            vc.transitioningDelegate = bottomSheetTransition
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true)
        }
    }
}

extension ViewController {
    enum DemoType: CaseIterable {
        case loading
        case bottomSheet

        var title: String {
            switch self {
            case .loading:
                return "Loadding"
            case .bottomSheet:
                return "BottomSheet"
            }
        }
    }
}


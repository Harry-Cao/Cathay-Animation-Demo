//
//  PanModalViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/27.
//

import UIKit
import SnapKit
import PanModal

class PanModalViewController: UIViewController {

    private(set) var container: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        [container, tableView].forEach(view.addSubview)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension PanModalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = "title"
        return cell
    }
}

extension PanModalViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return tableView
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(400)
    }
    var showDragIndicator: Bool {
        return false
    }
    var anchorModalToLongForm: Bool {
        return true
    }
    var isHapticFeedbackEnabled: Bool {
        return false
    }
    var panModalBackgroundColor: UIColor {
        return .black.withAlphaComponent(0.1)
    }
}

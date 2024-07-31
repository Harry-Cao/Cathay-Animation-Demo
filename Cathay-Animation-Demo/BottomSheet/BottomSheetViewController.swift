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
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
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

extension BottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = "title"
        return cell
    }
}

// MARK: - BottomSheetPresentable
extension BottomSheetViewController: BottomSheetPresentable {
    var contentHeight: CGFloat {
        return 400
    }
    var panScrollable: UIScrollView? {
        return tableView
    }
}

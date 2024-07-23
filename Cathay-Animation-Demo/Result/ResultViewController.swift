//
//  ResultViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit

class ResultViewController: UIViewController {
    var dataSource: [Int]?
    private let headerView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size.height = UIScreen.main.bounds.height
        imageView.backgroundColor = .red
        return imageView
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableHeaderView = headerView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "\(ResultTableViewCell.self)")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestData()
    }

    private func setupUI() {
        [tableView].forEach(view.addSubview)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func requestData() {
        tableView.isScrollEnabled = false
        MockNetworkHelper.mockRequestData { [weak self] data in
            guard let self = self else { return }
            dataSource = data
            tableView.isScrollEnabled = true
            tableView.reloadData()
            UIView.animate(withDuration: 0.3) { [self] in
                self.headerView.frame.size.height = 200
                self.headerView.layer.masksToBounds = true
                self.headerView.layer.cornerRadius = 40
                self.headerView.layer.maskedCorners = [.layerMinXMaxYCorner]
            }
        }
    }
}

extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = dataSource?[indexPath.row] else {
            let cell = UITableViewCell()
            cell.backgroundColor = .yellow
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ResultTableViewCell.self)", for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
    }
}

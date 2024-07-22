//
//  ResultViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit
import Hero

protocol ResultViewControllerDelegate {
    func onDismiss()
}

class ResultViewController: UIViewController {
    var delegate: ResultViewControllerDelegate?
    var dataSource: [Int]?
    private let headerView: UIImageView = {
        let imageView = UIImageView()
        imageView.heroID = "loading_imageView"
        imageView.frame.size.height = 200
        imageView.backgroundColor = .red
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner]
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

    init(dataSource: [Int] = []) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHeroEnabled = true
        setupUI()
    }

    private func setupUI() {
        [tableView].forEach(view.addSubview)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        self.isHeroEnabled = false
        delegate?.onDismiss()
    }
}

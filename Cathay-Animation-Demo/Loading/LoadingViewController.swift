//
//  LoadingViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit

class LoadingViewController: UIViewController {
    private var dataSource: [LoadingModel] = {
        var data = [LoadingModel]()
        for i in 0...20 {
            data.append(LoadingModel())
        }
        return data
    }()
    private var animationData = [LoadingModel]()
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
        tableView.sectionHeaderTopPadding = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "\(LoadingTableViewCell.self)")
        return tableView
    }()
    private let sectionHeader = TabView()
    private let navigationBarTransformer: NavigationBarTransformer = {
        let transformer = NavigationBarTransformer()
        transformer.setTransform(startOffset: 0.0, endOffset: 100.0)
        return transformer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestData()
    }

    private func setupUI() {
        sectionHeader.alpha = 0
        [tableView].forEach(view.addSubview)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func requestData() {
        navigationBarTransformer.delegate = self
        tableView.isScrollEnabled = false
        MockNetworkHelper.mockRequestData { [weak self] data in
            guard let self = self else { return }
            dataSource = data.map{ LoadingModel(num: $0) }
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = 200
                self.headerView.layer.masksToBounds = true
                self.headerView.layer.cornerRadius = 40
                self.headerView.layer.maskedCorners = [.layerMinXMaxYCorner]
            } completion: { _ in
                self.tableView.reloadData()
                self.sectionHeader.alpha = 1
                self.fadeInNext()
            }
        }
    }

    private func fadeInNext() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let self = self,
                  let nextIndex = animationData.firstIndex(where: { !$0.pop }),
                  let cell = tableView.cellForRow(at: IndexPath(row: nextIndex, section: 0)) as? LoadingTableViewCell else {
                self?.tableView.isScrollEnabled = true
                return
            }
            animationData[nextIndex].pop = true
            cell.fadeIn()
            fadeInNext()
        }
    }
}

extension LoadingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeader
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = dataSource[indexPath.row].num else {
            let cell = UITableViewCell()
            cell.backgroundColor = .yellow
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(LoadingTableViewCell.self)", for: indexPath) as! LoadingTableViewCell
        cell.setup(finishLoading: tableView.isScrollEnabled)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 68
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        animationData.append(data)
    }
}

extension LoadingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarTransformer.trackScrollView(scrollView)
        tableView.contentInsetAdjustmentBehavior = scrollView.contentOffset.y > 50 ? .always : .never
    }
}

extension LoadingViewController: NavigationBarTransformerDelegate {
    var transformerTargetNavigationBar: UINavigationBar? {
        return navigationController?.navigationBar
    }
}

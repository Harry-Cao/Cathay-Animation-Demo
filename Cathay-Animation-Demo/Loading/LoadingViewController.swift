//
//  LoadingViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit

class LoadingViewController: UIViewController {
    private var dataSource: [LoadingModel] = []
    private var animationData = [LoadingModel]()
    private let emptyHeaderView: UIView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: LoadingHeaderView.height)))
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableHeaderView = emptyHeaderView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "\(LoadingTableViewCell.self)")
        return tableView
    }()
    private let headerView: LoadingHeaderView = LoadingHeaderView(frame: .zero)
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
        navigationBarTransformer.delegate = self
        [tableView, headerView].forEach(view.addSubview)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerView.setState(.loading)
    }

    private func requestData() {
        tableView.isScrollEnabled = false
        MockNetworkHelper.mockRequestData { [weak self] data in
            guard let self = self else { return }
            dataSource = data.map{ LoadingModel(num: $0) }
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.headerView.setState(.sticky(process: 0))
            } completion: { _ in
                self.headerView.dateBar.select(index: 0)
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !tableView.isScrollEnabled else { return }
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

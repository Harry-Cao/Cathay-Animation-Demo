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
    private lazy var headerView: LoadingHeaderView = {
        let view = LoadingHeaderView()
        view.dateBar.delegate = self
        return view
    }()
    private lazy var scrollViewTracker: ScrollViewTracker = {
        let tracker = ScrollViewTracker()
        tracker.setTransform(startOffset: 0.0, endOffset: view.safeAreaInsets.top, factor: 1 / 3)
        tracker.delegate = self
        return tracker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setAlpha(0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setAlpha(1)
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.addSubview(headerView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view)
        }
    }

    private func requestData() {
        headerView.setState(.loading)
        tableView.isScrollEnabled = false
        MockNetworkHelper.mockRequestData { [weak self] data in
            guard let self = self else { return }
            dataSource = data.map{ LoadingModel(num: $0) }
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.headerView.setState(.normal)
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
        scrollViewTracker.trackScrollView(scrollView)
        if scrollView.contentOffset.y <= 0 {
            headerView.updateExtraHeight(abs(scrollView.contentOffset.y))
        }
    }
}

extension LoadingViewController: ScrollViewTrackerDelegate {
    func tracker(_ tracker: ScrollViewTracker, onScroll process: CGFloat) {
        headerView.updateDismissProcess(process, minimumHeight: view.safeAreaInsets.top)
    }
}

extension LoadingViewController: TabViewDelegate {
    func tabView(_ tabView: TabView, didSelect toIndex: Int, fromIndex: Int) {
        print("!!!didSelect toIndex: \(toIndex), fromIndex: \(fromIndex)")
    }
}

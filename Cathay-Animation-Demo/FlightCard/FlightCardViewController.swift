//
//  FlightCardViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit

class FlightCardViewController: UIViewController {
    private var currentIndex: Int = 0
    private var dataSource = [Int: [FlightCardModel]]()
    private var tabs = [TabModel]()
    private var displayingIndexPaths = Set<IndexPath>()
    private let emptyHeaderView: UIView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: FlightCardHeaderView.height)))
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        emptyHeaderView.isUserInteractionEnabled = false
        tableView.tableHeaderView = emptyHeaderView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FlightCardTableViewCell.self, forCellReuseIdentifier: "\(FlightCardTableViewCell.self)")
        return tableView
    }()
    private lazy var headerView: FlightCardHeaderView = {
        let view = FlightCardHeaderView()
        view.dateBar.delegate = self
        return view
    }()
    private lazy var scrollViewTracker: ScrollViewTracker = {
        let tracker = ScrollViewTracker()
        tracker.setTransform(startOffset: 0.0, endOffset: view.safeAreaInsets.top, factor: 1 / 3)
        tracker.delegate = self
        return tracker
    }()
    private var minimumCellNum: Int {
        return Int(ceil((UIScreen.main.bounds.height - FlightCardHeaderView.height) / FlightCardTableViewCell.height))
    }
    private var orderedDisplayingIndexPaths: [IndexPath] {
        displayingIndexPaths.sorted(by: { $0.row < $1.row })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDateBar()
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

    private func setupDateBar() {
        tabs = [
            TabModel(title: "Tab1"),
            TabModel(title: "Tab2"),
            TabModel(title: "Tab3"),
            TabModel(title: "Tab4"),
            TabModel(title: "Tab5"),
            TabModel(title: "Tab6"),
            TabModel(title: "Tab7"),
        ]
        headerView.dateBar.setTabs(tabs)
    }

    private func requestData() {
        view.isUserInteractionEnabled = false
        headerView.setState(.loading)
        MockNetworkHelper.mockRequestData(date: "") { [weak self] data in
            guard let self = self else { return }
            dataSource[currentIndex] = data.map{ FlightCardModel(num: $0) }
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.headerView.setState(.normal)
            } completion: { _ in
                self.headerView.dateBar.select(index: self.currentIndex)
                self.startFadeIn()
            }
        }
    }

    private func requestData(date: String) {
        MockNetworkHelper.mockRequestData(date: date) { [weak self] data in
            guard let self = self,
                  let index = tabs.firstIndex(where: { $0.date == date }) else { return }
            dataSource[index] = data.map{ FlightCardModel(num: $0) }
            if currentIndex == index {
                view.isUserInteractionEnabled = false
                tableView.reloadData()
                tableView.performBatchUpdates {
                    self.tableView.reloadData()
                } completion: { _ in
                    self.startFadeIn()
                }
            }
        }
    }
}

extension FlightCardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // prevent from animation error
        return max(minimumCellNum, dataSource[currentIndex]?.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = getModelFrom(index: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(FlightCardTableViewCell.self)", for: indexPath) as! FlightCardTableViewCell
        cell.setup(model: model, finishLoading: view.isUserInteractionEnabled)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FlightCardTableViewCell.height
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        displayingIndexPaths.insert(indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        displayingIndexPaths.remove(indexPath)
    }

    private func getModelFrom(index: Int) -> FlightCardModel? {
        guard let data = dataSource[currentIndex],
              !data.isEmpty,
              (0...max(0, data.count-1)).contains(index) else { return nil }
        return data[index]
    }
}

extension FlightCardViewController: UITableViewDelegate {
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

extension FlightCardViewController: ScrollViewTrackerDelegate {
    func tracker(_ tracker: ScrollViewTracker, onScroll process: CGFloat) {
        headerView.updateDismissProcess(process, minimumHeight: view.safeAreaInsets.top)
    }
}

extension FlightCardViewController: TabViewDelegate {
    func tabView(_ tabView: TabView, didSelect toIndex: Int, fromIndex: Int) {
        guard fromIndex != -1 else { return }
        currentIndex = toIndex
        if dataSource[toIndex] == nil {
            requestData(date: tabs[toIndex].date)
        }
        if toIndex != fromIndex {
            switchTo(index: toIndex, direction: toIndex > fromIndex ? .left : .right)
        }
    }
}

// MARK: - Animations
extension FlightCardViewController {
    private func startFadeIn() {
        view.isUserInteractionEnabled = false
        orderedDisplayingIndexPaths.enumerated().forEach { (index, indexPath) in
            let isLast: Bool = index == orderedDisplayingIndexPaths.count - 1
            let delay: Double = 0.1 * Double(index)
            let enableUserInteraction = { [weak self] in
                guard isLast else { return }
                self?.view.isUserInteractionEnabled = true
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath) as? FlightCardTableViewCell else {
                    enableUserInteraction()
                    return
                }
                cell.fadeIn {
                    enableUserInteraction()
                }
            }
        }
    }

    private func switchTo(index: Int, direction: SwitchDirection) {
        view.isUserInteractionEnabled = false
        orderedDisplayingIndexPaths.enumerated().forEach { (index, indexPath) in
            let isLast: Bool = index == orderedDisplayingIndexPaths.count - 1
            let enableUserInteraction = { [weak self] in
                guard isLast else { return }
                self?.view.isUserInteractionEnabled = true
                self?.tableView.reloadData()
            }
            guard let cell = tableView.cellForRow(at: indexPath) as? FlightCardTableViewCell else {
                enableUserInteraction()
                return
            }
            let model = getModelFrom(index: index)
            cell.switchTo(model: model, direction: direction, extraDuration: 0.1 * Double(index)) {
                enableUserInteraction()
            }
        }
    }
}

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
    private let shortenFactor: CGFloat = 1 / 3
    private lazy var anchoredContentOffsetY: CGFloat = {
        let topSafeInset = view.safeAreaInsets.top
        let offsetY = (FlightCardAnimationView.height - topSafeInset) / shortenFactor
        return offsetY
    }()
    private var isMainScrollViewAnchored: Bool {
        return mainScrollView.contentOffset.y >= anchoredContentOffsetY
    }

    private lazy var headerView: FlightCardHeaderView = {
        let view = FlightCardHeaderView()
        view.dateBar.delegate = self
        return view
    }()
    private lazy var mainScrollView: FlightCardMainScrollView = {
        let view = FlightCardMainScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.delegate = self
        view.gestureDelegate = self
        return view
    }()
    private lazy var scrollViewTracker: ScrollViewTracker = {
        let tracker = ScrollViewTracker()
        tracker.setTransform(startOffset: 0.0, endOffset: view.safeAreaInsets.top, factor: shortenFactor)
        tracker.delegate = self
        return tracker
    }()
    private let pageController = FlightCardPageController()
    private var currentPage: FlightCardPage? {
        return pageController.currentPage
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setAlpha(0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setAlpha(1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPageController()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(mainScrollView)
        addChild(pageController)
        [pageController.view, headerView].forEach(mainScrollView.addSubview)
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(FlightCardHeaderView.height)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0)
            make.width.equalTo(view)
        }
        headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view)
        }
    }

    private func layoutPageController() {
        let pageHeight = view.bounds.height - FlightCardHeaderView.height + anchoredContentOffsetY
        pageController.view.snp.updateConstraints { make in
            make.height.equalTo(pageHeight)
        }
    }

    private func loadData() {
        view.isUserInteractionEnabled = false
        headerView.setState(.loading)
        MockNetworkHelper.requestData { [weak self] data in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                self.headerView.setState(.normal)
            } completion: { _ in
                self.view.isUserInteractionEnabled = true
                self.headerView.dateBar.setTabs(data.map({ TabModel(title: "\($0.date) flights: \($0.flights.count)") }))
                self.pageController.pages = data.map({
                    let page = FlightCardPage(date: $0.date)
                    page.delegate = self
                    return page
                })
                self.headerView.dateBar.select(index: self.currentIndex)
                self.pageController.select(index: self.currentIndex, direction: .forward)
            }
        }
    }
}

extension FlightCardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewTracker.trackScrollView(scrollView)
        if scrollView.contentOffset.y <= 0 {
            headerView.updateExtraHeight(abs(scrollView.contentOffset.y))
        }
        didPanOnMainScrollView(scrollView)
    }

    private func didPanOnMainScrollView(_ scrollView: UIScrollView) {
        guard let currentPage else { return }
        if currentPage.tableView.contentOffset.y > 0 {
            scrollView.contentOffset = CGPoint(x: .zero, y: anchoredContentOffsetY)
        }
        if isMainScrollViewAnchored && currentPage.tableView.contentOffset.y == 0 {
            scrollView.contentOffset = CGPoint(x: .zero, y: anchoredContentOffsetY)
        }
    }
}

extension FlightCardViewController: ScrollViewTrackerDelegate {
    func tracker(_ tracker: ScrollViewTracker, onScroll process: CGFloat) {
        headerView.updateDismissProcess(process, minimumHeight: view.safeAreaInsets.top)
    }
}

// MARK: - FlightCardPageDelegate
extension FlightCardViewController: FlightCardPageDelegate {
    func pageViewDidPanOnScrollView(_ scrollView: UIScrollView) {
        if !isMainScrollViewAnchored {
            scrollView.contentOffset = .zero
        } else {
            mainScrollView.contentOffset = CGPoint(x: .zero, y: anchoredContentOffsetY)
        }
    }
}

extension FlightCardViewController: TabViewDelegate {
    func tabView(_ tabView: TabView, didSelect toIndex: Int, fromIndex: Int) {
        guard currentIndex != toIndex else { return }
        currentPage?.tableView.setContentOffset(.zero, animated: true)
        mainScrollView.setContentOffset(.zero, animated: true)
        let direction: UIPageViewController.NavigationDirection = toIndex > currentIndex ? .forward : .reverse
        pageController.select(index: toIndex, direction: direction)
        currentIndex = toIndex
    }
}

// MARK: - FlightCardMainScrollViewGestureDelegate
extension FlightCardViewController: FlightCardMainScrollViewGestureDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view == currentPage?.tableView
    }
}

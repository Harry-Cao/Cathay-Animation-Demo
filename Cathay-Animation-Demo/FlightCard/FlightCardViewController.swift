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
    private var dataSource = [DateResultModel]()
    private var pages = [FlightCardPage]()
    private var scrollObserver: NSKeyValueObservation?
    private var pageScrollViewYOffset: CGFloat = 0.0
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
        return view
    }()
    private lazy var scrollViewTracker: ScrollViewTracker = {
        let tracker = ScrollViewTracker()
        tracker.setTransform(startOffset: 0.0, endOffset: view.safeAreaInsets.top, factor: shortenFactor)
        tracker.delegate = self
        return tracker
    }()
    private lazy var pageController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        controller.delegate = self
        return controller
    }()
    private var currentPage: FlightCardPage? {
        guard !pages.isEmpty,
              (0...pages.count-1).contains(currentIndex) else { return nil }
        return pages[currentIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observe()
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

    private func observe() {
        scrollObserver?.invalidate()
        scrollObserver = mainScrollView.observe(\.contentOffset, options: .old) { [weak self] scrollView, _ in
            guard let self else { return }
            didPanOnMainScrollView(scrollView)
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
                self.pages = data.map({
                    let page = FlightCardPage(date: $0.date)
                    page.delegate = self
                    return page
                })
                self.headerView.dateBar.select(index: self.currentIndex)
                guard let firstPage = self.pages.first else { return }
                self.pageController.setViewControllers([firstPage], direction: .forward, animated: false)
            }
        }
    }
}

// MARK: - FlightCardPageDelegate
extension FlightCardViewController: FlightCardPageDelegate {
    func pageViewDidPanOnScrollView(_ scrollView: UIScrollView) {
        if !isMainScrollViewAnchored && mainScrollView.contentOffset.y <= .zero && scrollView.contentOffset.y <= .zero {
            scrollView.setContentOffset(CGPoint(x: .zero, y: pageScrollViewYOffset), animated: false)
        } else {
            pageScrollViewYOffset = scrollView.contentOffset.y
        }
    }
}

extension FlightCardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewTracker.trackScrollView(scrollView)
        if scrollView.contentOffset.y <= 0 {
            headerView.updateExtraHeight(abs(scrollView.contentOffset.y))
        }
    }

    private func didPanOnMainScrollView(_ scrollView: UIScrollView) {
        guard let currentPage else { return }
        if isMainScrollViewAnchored && currentPage.tableView.contentOffset.y > 0 {
            scrollView.setContentOffset(CGPoint(x: .zero, y: anchoredContentOffsetY), animated: false)
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
        guard currentIndex != toIndex else { return }
        let direction: UIPageViewController.NavigationDirection = toIndex > currentIndex ? .forward : .reverse
        let vc = pages[toIndex]
        pageController.setViewControllers([vc], direction: direction, animated: true)
        currentIndex = toIndex
    }
}

extension FlightCardViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("!!!willTransitionTo: \(pages.firstIndex(of: pendingViewControllers.first! as! FlightCardPage)!)")
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("!!!didFinishAnimating: \(pages.firstIndex(of: previousViewControllers.first! as! FlightCardPage)!)")
    }
}

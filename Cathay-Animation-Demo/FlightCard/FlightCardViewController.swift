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

    private lazy var headerView: FlightCardHeaderView = {
        let view = FlightCardHeaderView()
        view.dateBar.delegate = self
        return view
    }()
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
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
        guard (0...pages.count-1).contains(currentIndex) else { return nil }
        return pages[currentIndex]
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
        view.addSubview(scrollView)
        addChild(pageController)
        [pageController.view, headerView].forEach(scrollView.addSubview)
        scrollView.snp.makeConstraints { make in
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
        let topSafeInset = view.safeAreaInsets.top
        let extraHeight = (200 - topSafeInset) / shortenFactor
        let pageHeight = view.bounds.height - FlightCardHeaderView.height + extraHeight
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
        
    }
}

extension FlightCardViewController: UIScrollViewDelegate {
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

extension FlightCardViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let currentPage = currentPage else { return false }
        return otherGestureRecognizer.view == currentPage.tableView
    }
}

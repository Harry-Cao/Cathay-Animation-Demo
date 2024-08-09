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
        view.panGestureRecognizer.delegate = self
        return view
    }()
    private lazy var scrollViewTracker: ScrollViewTracker = {
        let tracker = ScrollViewTracker()
        tracker.setTransform(startOffset: 0.0, endOffset: view.safeAreaInsets.top, factor: shortenFactor)
        tracker.delegate = self
        return tracker
    }()
    private lazy var pageController: FlightCardPageController = {
        let controller = FlightCardPageController()
//        controller.delegate = self
        return controller
    }()

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
            make.height.equalTo(1000)
            make.width.equalTo(view)
        }
        headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view)
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
                self.pageController.pages = data.map({ FlightCardPage(date: $0.date) })
                self.headerView.dateBar.select(index: self.currentIndex)
                guard let firstPage = self.pageController.pages.first else { return }
                self.pageController.setViewControllers([firstPage], direction: .forward, animated: false)
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
        let vc = pageController.pages[toIndex]
        self.pageController.setViewControllers([vc], direction: direction, animated: true)
        currentIndex = toIndex
    }
}

extension FlightCardViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("!!!willTransitionTo: \(pageController.pages.firstIndex(of: pendingViewControllers.first! as! FlightCardPage)!)")
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("!!!didFinishAnimating: \(pageController.pages.firstIndex(of: previousViewControllers.first! as! FlightCardPage)!)")
    }
}

extension FlightCardViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

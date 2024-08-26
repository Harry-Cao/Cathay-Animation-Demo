//
//  FlightCardViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit
import Combine

class FlightCardViewController: UIViewController {
    private var currentIndex: Int = 0
    private let shortenFactor: CGFloat = 1 / 3
    private var topSafeInset: CGFloat = 0.0
    private var anchoredContentOffsetY: CGFloat = 0.0
    private var isMainScrollViewAnchored: Bool {
        return mainScrollView.contentOffset.y.rounded() >= anchoredContentOffsetY.rounded()
    }
    private var isSetupLayout: Bool = false
    private let viewModel = FlightCardViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var headerView: FlightCardHeaderView = {
        let view = FlightCardHeaderView()
        view.dateBar.delegate = self
        view.animationView.delegate = self
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
        tracker.setTransform(startOffset: 0.0, endOffset: topSafeInset, factor: shortenFactor)
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
        bindData()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // To align height of system navigationBar, we could remove if needn't align.
        navigationController?.navigationBar.setAlpha(0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // To align height of system navigationBar, we could remove if needn't align.
        navigationController?.navigationBar.setAlpha(1)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // To align height of system navigationBar, we could remove if needn't align.
        if !isSetupLayout {
            isSetupLayout = true
            topSafeInset = view.safeAreaInsets.top
            anchoredContentOffsetY = view.safeAreaInsets.top / shortenFactor
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
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

    private func bindData() {
        viewModel.$isAnimating.sink { [weak self] isAnimating in
            self?.view.isUserInteractionEnabled = !isAnimating
        }.store(in: &cancellables)
    }

    private func layoutPageController() {
        let pageHeight = view.bounds.height - FlightCardHeaderView.height + anchoredContentOffsetY
        pageController.view.snp.updateConstraints { make in
            make.height.equalTo(pageHeight)
        }
    }

    private func loadData() {
        headerView.setState(.loading)
        viewModel.isAnimating = true
        MockNetworkHelper.requestData { [weak self] data in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                self.headerView.setState(.normal)
            } completion: { _ in
                self.viewModel.isAnimating = false
                self.headerView.animationView.backButton.isHidden = false
                self.headerView.dateBar.setTabs(data.map({ TabModel(title: "\($0.date) flights: \($0.flights.count)") }))
                self.pageController.pages = data.map({
                    let page = FlightCardPage(date: $0.date, viewModel: self.viewModel)
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
        handleScrolling(scrollView)
    }

    private func handleScrolling(_ scrollView: UIScrollView) {
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
        headerView.updateDismissProcess(process, minimumHeight: topSafeInset)
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

extension FlightCardViewController: FlightCardAnimationViewDelegate {
    func didTapOnBackButton() {
        self.dismiss(animated: true)
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

//
//  FlightCardPageController.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/7.
//

import UIKit

class FlightCardPageController: UIPageViewController {
    var pages = [FlightCardPage]()
    private(set) var currentPage: FlightCardPage?

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        dataSource = self
//        delegate = self
        view.backgroundColor = .systemBackground
    }

    func select(index: Int,
                direction: UIPageViewController.NavigationDirection,
                animated: Bool = true,
                completion: ((Bool) -> Void)? = nil) {
        guard let page = getPage(index: index) else { return }
        currentPage = page
        let isPageLoaded: Bool = !page.displayingIndexPaths.isEmpty
        if isPageLoaded {
            page.prepareFlyIn(direction: direction)
        }
        setViewControllers([page], direction: direction, animated: animated, completion: completion)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if isPageLoaded {
                page.flyIn(direction: direction)
            }
        }
    }

    private func getPage(index: Int) -> FlightCardPage? {
        guard !pages.isEmpty,
              (0...pages.count-1).contains(index) else { return nil }
        return pages[index]
    }
}

extension FlightCardPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? FlightCardPage,
              let index = pages.firstIndex(of: vc),
              let page = getPage(index: index - 1) else { return nil }
        return page
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? FlightCardPage,
              let index = pages.firstIndex(of: vc),
              let page = getPage(index: index + 1) else { return nil }
        return page
    }
}

extension FlightCardPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("!!!willTransitionTo: \(pages.firstIndex(of: pendingViewControllers.first! as! FlightCardPage)!)")
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("!!!didFinishAnimating: \(pages.firstIndex(of: previousViewControllers.first! as! FlightCardPage)!)")
    }
}

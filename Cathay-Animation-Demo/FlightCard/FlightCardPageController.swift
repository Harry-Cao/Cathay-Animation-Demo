//
//  FlightCardPageController.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/7.
//

import UIKit

class FlightCardPageController: UIPageViewController {
    var pages = [FlightCardPage]()

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.dataSource = self
        view.backgroundColor = .systemBackground
    }

}

extension FlightCardPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? FlightCardPage,
              let index = pages.firstIndex(of: vc),
              (0...pages.count-1).contains(index - 1) else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? FlightCardPage,
              let index = pages.firstIndex(of: vc),
              (0...pages.count-1).contains(index + 1) else { return nil }
        return pages[index + 1]
    }
}

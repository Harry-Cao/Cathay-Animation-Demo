//
//  ViewController.swift
//  Cathay-Animation-Demo
//
//  Created by HarryCao on 2024/7/22.
//

import UIKit
import SnapKit
import PanModal

class ViewController: UIViewController {

    private let dataSource: [DemoType] = DemoType.allCases
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        return tableView
    }()
    private let bottomSheetTransition = BottomSheetTransition()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = type.title
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = dataSource[indexPath.row]
        switch type {
        case .flightCard:
            let vc = FlightCardViewController()
            let naviVC = UINavigationController(rootViewController: vc)
            naviVC.modalPresentationStyle = .fullScreen
            self.present(naviVC, animated: true)
        case .bottomSheet_selfMake:
            let vc = BottomSheetViewController()
            vc.transitioningDelegate = bottomSheetTransition
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true)
        case .bottomSheet_system:
            let vc = BottomSheetViewController()
            let naviVC = UINavigationController(rootViewController: vc)
            naviVC.modalPresentationStyle = .formSheet
            let sheet = naviVC.sheetPresentationController
            sheet?.detents = [.medium()]
            self.present(naviVC, animated: true)
        case .bottomSheet_panModal:
            let vc = PanModalViewController()
            self.presentPanModal(vc)
        case .airbnb_calender:
            let vc = AirbnbCalenderViewController()
            self.present(vc, animated: true)
        }
    }
}

extension ViewController {
    enum DemoType: CaseIterable {
        case flightCard
        case bottomSheet_selfMake
        case bottomSheet_system
        case bottomSheet_panModal
        case airbnb_calender

        var title: String {
            switch self {
            case .flightCard:
                return "Flight Card"
            case .bottomSheet_selfMake:
                return "BottomSheet Self Make"
            case .bottomSheet_system:
                return "BottomSheet System (iOS 15+)"
            case .bottomSheet_panModal:
                return "BottomSheet PanModal"
            case .airbnb_calender:
                return "Airbnb Calender"
            }
        }
    }
}


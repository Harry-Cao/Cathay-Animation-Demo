//
//  FlightCardPage.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/7.
//

import UIKit

protocol FlightCardPageDelegate: AnyObject {
    func pageViewDidPanOnScrollView(_ scrollView: UIScrollView)
}

class FlightCardPage: UIViewController {
    weak var delegate: FlightCardPageDelegate?
    private let date: String
    private let superViewModel: FlightCardViewModel
    private var flightModels = [FlightCardModel]()
    private(set) var displayingIndexPaths = Set<IndexPath>()
    private var sortedDisplayingIndexPaths: [IndexPath] {
        return displayingIndexPaths.sorted(by: { $0.row < $1.row })
    }
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FlightCardTableViewCell.self, forCellReuseIdentifier: "\(FlightCardTableViewCell.self)")
        return tableView
    }()

    init(date: String, viewModel: FlightCardViewModel) {
        self.date = date
        self.superViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestData()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func requestData() {
        MockNetworkHelper.requestFlights(date: date) { [weak self] models in
            guard let self = self else { return }
            flightModels = models.map({ FlightCardModel(id: $0.id) })
            superViewModel.isAnimating = true
            tableView.reloadData()
            tableView.performBatchUpdates {
                self.tableView.reloadData()
            } completion: { _ in
                self.fadeIn()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension FlightCardPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flightModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let flightModel = flightModels[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(FlightCardTableViewCell.self)", for: indexPath) as? FlightCardTableViewCell else {
            fatalError("TableView only support FlightCardTableViewCell")
        }
        cell.setup(flightModel: flightModel, finishLoading: superViewModel.isAnimating == false)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FlightCardPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        displayingIndexPaths.insert(indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        displayingIndexPaths.remove(indexPath)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pageViewDidPanOnScrollView(scrollView)
    }
}

// MARK: - Animation
extension FlightCardPage {
    private func fadeIn() {
        superViewModel.isAnimating = true
        enumerateDisplayingCells { [weak self] cell, index, isLast in
            let delay: Double = 0.1 * Double(index)
            cell.fadeIn(delay: delay) {
                if isLast {
                    self?.tableView.reloadData()
                    self?.superViewModel.isAnimating = false
                }
            }
        }
    }

    func prepareFlyIn(direction: UIPageViewController.NavigationDirection) {
        enumerateDisplayingCells { cell, index, _ in
            let offset: CGFloat = CGFloat(40 * index) * (direction == .forward ? 1 : -1)
            cell.prepareFlyIn(offset: offset)
        }
    }

    func flyIn(direction: UIPageViewController.NavigationDirection) {
        superViewModel.isAnimating = true
        enumerateDisplayingCells { [weak self] cell, index, isLast in
            let duration: TimeInterval = 0.2 + 0.05 * Double(index)
            cell.flyIn(duration: duration) {
                if isLast {
                    self?.tableView.reloadData()
                    self?.superViewModel.isAnimating = false
                }
            }
        }
    }

    private func enumerateDisplayingCells(animate: (_ cell: FlightCardTableViewCell,
                                                    _ index: Int,
                                                    _ isLast: Bool) -> Void) {
        let indexPaths = sortedDisplayingIndexPaths
        indexPaths.enumerated().forEach { (index, indexPath) in
            let isLast: Bool = index == indexPaths.count - 1
            guard let cell = tableView.cellForRow(at: indexPath) as? FlightCardTableViewCell else {
                fatalError("TableView only support FlightCardTableViewCell")
            }
            cell.layer.removeAllAnimations()
            animate(cell, index, isLast)
        }
    }
}

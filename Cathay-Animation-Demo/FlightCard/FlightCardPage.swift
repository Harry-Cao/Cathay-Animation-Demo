//
//  FlightCardPage.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/8/7.
//

import UIKit

class FlightCardPage: UIViewController {
    weak var delegate: FlightCardPageDelegate?
    private let date: String
    private var flightModels = [FlightCardModel]()
    private var animationCache = [FlightCardModel]()
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

    init(date: String) {
        self.date = date
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
        tableView.isScrollEnabled = false
        MockNetworkHelper.requestFlights(date: date) { [weak self] models in
            guard let self = self else { return }
            flightModels = models.map({ FlightCardModel(id: $0.id) })
            tableView.reloadData()
            fadeInNext()
        }
    }

    private func fadeInNext() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let self = self,
                  let nextIndex = animationCache.firstIndex(where: { !$0.pop }),
                  let cell = tableView.cellForRow(at: IndexPath(row: nextIndex, section: 0)) as? FlightCardTableViewCell else {
                self?.tableView.isScrollEnabled = true
                return
            }
            cell.fadeIn()
            animationCache[nextIndex].pop = true
            fadeInNext()
        }
    }

}

extension FlightCardPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flightModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let flightModel = flightModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(FlightCardTableViewCell.self)", for: indexPath) as! FlightCardTableViewCell
        cell.setup(flightModel: flightModel, finishLoading: tableView.isScrollEnabled)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !tableView.isScrollEnabled else { return }
        let flightModel = flightModels[indexPath.row]
        animationCache.append(flightModel)
    }
}

extension FlightCardPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pageViewDidPanOnScrollView(scrollView)
    }
}

//
//  MockNetworkHelper.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/23.
//

import Foundation

struct MockNetworkHelper {
    static func requestData(callBack: @escaping ([DateResultModel]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            var dataSource = [DateResultModel]()
            (0...7).forEach {
                let randomNum = Int.random(in: 0...20)
                let flights = (0...randomNum).map({ FlightCardModel(id: $0) })
                dataSource.append(DateResultModel(date: "Day \($0)", flights: flights))
            }
            callBack(dataSource)
        }
    }

    static func requestFlights(date: String, callBack: @escaping ([FlightModel]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            let randomNum = Int.random(in: 0...20)
            let flights = (0...randomNum).map({ FlightModel(id: $0, date: date) })
            callBack(flights)
        }
    }
}

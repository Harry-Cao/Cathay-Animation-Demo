//
//  FlightCardModel.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/23.
//

import Foundation

enum SwitchDirection {
    case left
    case right
}

final class FlightCardModel {
    var num: Int?
    var pop: Bool = false

    init(num: Int? = nil) {
        self.num = num
    }
}

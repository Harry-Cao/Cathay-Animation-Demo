//
//  TabModel.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/29.
//

import Foundation

class TabModel {
    let title: String
    let date: String = UUID().uuidString

    init(title: String) {
        self.title = title
    }
}

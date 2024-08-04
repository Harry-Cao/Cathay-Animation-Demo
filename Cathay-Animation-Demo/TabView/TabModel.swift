//
//  TabModel.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/29.
//

import Foundation

class TabModel {
    var title: String?

    init(title: String? = nil) {
        self.title = title
    }
}

extension TabModel {
    static var loading: TabModel {
        return TabModel()
    }
}

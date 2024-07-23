//
//  MockNetworkHelper.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/23.
//

import Foundation

struct MockNetworkHelper {
    static func mockRequestData(callBack: @escaping ([Int]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            var dataSource = [Int]()
            for i in 0...20 {
                dataSource.append(i)
            }
            callBack(dataSource)
        }
    }
}

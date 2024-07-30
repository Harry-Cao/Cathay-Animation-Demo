//
//  TabViewDelegate.swift
//  Cathay-Animation-Demo
//
//  Created by harry.weixian.cao on 2024/7/30.
//

import Foundation

protocol TabViewDelegate: AnyObject {
    func tabView(_ tabView: TabView, didSelect toIndex: Int, fromIndex: Int)
}

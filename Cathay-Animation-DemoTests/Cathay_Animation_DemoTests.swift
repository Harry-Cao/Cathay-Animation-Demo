//
//  Cathay_Animation_DemoTests.swift
//  Cathay-Animation-DemoTests
//
//  Created by harry.weixian.cao on 2024/8/2.
//

import XCTest
@testable import Cathay_Animation_Demo

final class Cathay_Animation_DemoTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testScrollTracker() throws {
        var offsetY: CGFloat = 0.0
        let scrollTracker = ScrollViewTracker()
        scrollTracker.setTransform(startOffset: 0, endOffset: 100)
        offsetY = -10
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 0)
        offsetY = 0
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 0)
        offsetY = 10
        XCTAssertTrue(scrollTracker.process(from: offsetY) > 0 && scrollTracker.process(from: offsetY) < 1)
        offsetY = 100
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 1)
        offsetY = 110
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 1)

        scrollTracker.setTransform(startOffset: 0, endOffset: -100)
        offsetY = 10
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 0)
        offsetY = 0
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 0)
        offsetY = -10
        XCTAssertTrue(scrollTracker.process(from: offsetY) > 0 && scrollTracker.process(from: offsetY) < 1)
        offsetY = -100
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 1)
        offsetY = -110
        XCTAssertTrue(scrollTracker.process(from: offsetY) == 1)
    }

}

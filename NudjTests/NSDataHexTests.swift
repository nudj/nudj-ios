//
//  NSDataHexTests.swift
//  Nudj
//
//  Created by Richard Buckle on 16/02/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import XCTest
@testable import Nudj

class NDDataHexTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyData() {
        let data = NSData()
        let hex = data.hexString()
        XCTAssert(hex.isEmpty)
    }
    
}

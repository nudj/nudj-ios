//
//  ArraySectionsTests.swift
//  Nudj
//
//  Created by Richard Buckle on 04/07/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import XCTest
@testable import Nudj

class ArraySectionsTests: XCTestCase {
    
    func alwaysSplitPredicate(_: String, _: String) -> Bool {
        return true
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmpty() {
        let array = [String]()
        let result = array.sectionsSplitBy(alwaysSplitPredicate)
        XCTAssertEqual(result, [])
    }
}

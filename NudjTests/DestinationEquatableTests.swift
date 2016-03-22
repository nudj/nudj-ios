//
//  DestinationEquatableTests.swift
//  Nudj
//
//  Created by Richard Buckle on 22/03/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import XCTest
import Nudj

class DestinationEquatableTests: XCTestCase {
    
    func expectEqual(lhs: Destination, _ rhs: Destination) {
        XCTAssertEqual(lhs, rhs)
    }
    
    func expectNotEqual(lhs: Destination, _ rhs: Destination) {
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testNoneEqualsNone() {
        expectEqual(.None, .None)
    }
    
    func testNoneDoesNotEqualJob() {
        expectNotEqual(.None, .Job(42))
    }
    
    func testJobDoesNotEqualNone() {
        expectNotEqual(.Job(42), .None)
    }
    
    func testJobEqualsSameJob() {
        expectEqual(.Job(42), .Job(42))
    }
    
    func testJobDoesNotEqualOtherJob() {
        expectNotEqual(.Job(42), .Job(43))
    }
}

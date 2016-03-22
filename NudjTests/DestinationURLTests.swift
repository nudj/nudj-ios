//
//  DestinationURLTests.swift
//  Nudj
//
//  Created by Richard Buckle on 22/03/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import XCTest
@testable import Nudj

class DestinationURLTests: XCTestCase {
    
    func testNoneEqualsNone() {
        let lhs = Destination.None
        let rhs = Destination.None
        XCTAssertEqual(lhs, rhs)
    }

    func testNoneDoesNotEqualJob() {
        let lhs = Destination.None
        let rhs = Destination.Job(42)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testJobEqualsSameJob() {
        let lhs = Destination.Job(42)
        let rhs = Destination.Job(42)
        XCTAssertEqual(lhs, rhs)
    }
    
    func testJobDoesNotEqualOtherJob() {
        let lhs = Destination.Job(42)
        let rhs = Destination.Job(43)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testIncorrectDomain() {
        let url = NSURL(string: "http://example.com/")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }
    
    func testCorrectHTTPSURL() {
        let url = NSURL(string: "https://mobileweb.nudj.co/jobpreview/42/abcd")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.Job(42))
    }
}

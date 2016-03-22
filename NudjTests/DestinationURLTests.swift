//
//  DestinationURLTests.swift
//  Nudj
//
//  Created by Richard Buckle on 22/03/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import XCTest
import Nudj

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
    
    func testJobDoesNotEqualNone() {
        let lhs = Destination.Job(42)
        let rhs = Destination.None
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
    
    func testNoPath() {
        let url = NSURL(string: "https://mobileweb.nudj.co/")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }
    
    func testCorrectHTTPSURL() {
        let url = NSURL(string: "https://mobileweb.nudj.co/jobpreview/42/abcd")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.Job(42))
    }
    
    func testCorrectHTTPURL() {
        let url = NSURL(string: "http://mobileweb.nudj.co/jobpreview/42/abcd")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.Job(42))
    }
    
    func testCorrectDifferentJobID() {
        let url = NSURL(string: "https://mobileweb.nudj.co/jobpreview/43/abcd")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.Job(43))
    }
    
    func testMalformedJobID() {
        let url = NSURL(string: "https://mobileweb.nudj.co/jobpreview/abcd")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }
    
    func testMissingJobID() {
        let url = NSURL(string: "https://mobileweb.nudj.co/jobpreview/")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }
    
    func testIrrelevantPath() {
        let url = NSURL(string: "https://mobileweb.nudj.co/foo/bar/baz/quux")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }

    func testWrongScheme() {
        let url = NSURL(string: "xmpp://mobileweb.nudj.co/jobpreview/42/abcd")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }
    
    func testWrongHost() {
        let url = NSURL(string: "https://nudj.co/jobpreview/42/abcd")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }
    
    func testHashDoesntMatter() {
        let url = NSURL(string: "https://mobileweb.nudj.co/jobpreview/42/wxyz")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.Job(42))
    }
    
    func testHashNotRequired() {
        let url = NSURL(string: "https://mobileweb.nudj.co/jobpreview/42")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.Job(42))
    }
}

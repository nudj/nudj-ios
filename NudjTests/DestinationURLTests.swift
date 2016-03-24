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
    
    func expect(urlString: String, toGive expectedDestination: Destination) {
        let url = NSURL(string: urlString)
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, expectedDestination)
    }
    
    func testIncorrectDomain() {
        expect("http://example.com/", toGive: .None)
    }
    
    func testNotEvenHostAndPath() {
        expect("mailto:", toGive: .None)
    }
    
    func testNoPath() {
        expect("https://mobileweb.nudj.co/", toGive: .None)
    }
    
    func testCorrectHTTPSURL() {
        expect("https://mobileweb.nudj.co/jobpreview/42/abcd", toGive: .Job(42))
    }
    
    func testCorrectDevHTTPSURL() {
        expect("https://mobileweb-dev.nudj.co/jobpreview/42/abcd", toGive: .Job(42))
    }
    
    func testCorrectNonPreviewURL() {
        expect("https://mobileweb.nudj.co/job/42/abcd", toGive: .Job(42))
    }
    
    func testCorrectHTTPURL() {
        expect("http://mobileweb.nudj.co/jobpreview/42/abcd", toGive: .Job(42))
    }
    
    func testCorrectDifferentJobID() {
        expect("https://mobileweb.nudj.co/jobpreview/43/abcd", toGive: .Job(43))
    }
    
    func testMalformedJobID() {
        expect("https://mobileweb.nudj.co/jobpreview/abcd", toGive: .None)
    }
    
    func testMissingJobID() {
        expect("https://mobileweb.nudj.co/jobpreview/", toGive: .None)
    }
    
    func testIrrelevantPath() {
        expect("https://mobileweb.nudj.co/foo/bar/baz/quux", toGive: .None)
    }

    func testWrongScheme() {
        expect("xmpp://mobileweb.nudj.co/jobpreview/42/abcd", toGive: .None)
    }
    
    func testWrongHost() {
        expect("https://nudj.co/jobpreview/42/abcd", toGive: .None)
    }
    
    func testHashDoesntMatter() {
        expect("https://mobileweb.nudj.co/jobpreview/42/wxyz", toGive: .Job(42))
    }
    
    func testHashNotRequired() {
        expect("https://mobileweb.nudj.co/jobpreview/42", toGive: .Job(42))
    }
}

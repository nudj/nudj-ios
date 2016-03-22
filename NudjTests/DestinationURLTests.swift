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

    func testIncorrectDomain() {
        let url = NSURL(string: "http://example.com/")
        let destination = Destination(url: url!)
        XCTAssertEqual(destination, Destination.None)
    }
}

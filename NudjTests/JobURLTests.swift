//
//  JobURLTests.swift
//  Nudj
//
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import XCTest
@testable import Nudj

class JobURLTests: XCTestCase {
    var hostname: String = ""
    
    override func setUp() {
        super.setUp()
        let api = API()
        hostname = api.server.mobileWebHostname
    }
    
    func testMainURL() {
        let jobURL: JobURL = .Main(42)
        let url = jobURL.url()
        let expectedURL = NSURL(string: "https://\(hostname)/job/42")!
        XCTAssertEqual(url, expectedURL)
    }
    
    func testPreviewURL() {
        let jobURL: JobURL = .Preview(42)
        let url = jobURL.url()
        let expectedURL = NSURL(string: "https://\(hostname)/jobpreview/42")!
        XCTAssertEqual(url, expectedURL)
    }
}

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
    
    func testEmptyData() {
        let data = NSData()
        let hex = data.hexString()
        XCTAssert(hex.isEmpty)
    }
    
    func test1x0Byte() {
        let data = NSMutableData(length: 1)
        let hex = data!.hexString()
        XCTAssertEqual(hex, "00")
    }
    
    func test1x15Byte() {
        let data = NSMutableData(length: 1)
        let bytes = UnsafeMutablePointer<UInt8>(data!.mutableBytes)
        bytes[0] = 15
        let hex = data!.hexString()
        XCTAssertEqual(hex, "0f")
    }
    
    func test1x255Byte() {
        let data = NSMutableData(length: 1)
        let bytes = UnsafeMutablePointer<UInt8>(data!.mutableBytes)
        bytes[0] = 255
        let hex = data!.hexString()
        XCTAssertEqual(hex, "ff")
    }
    
    func test32x0Byte() {
        let data = NSMutableData(length: 32)
        let hex = data!.hexString()
        XCTAssertEqual(hex, String(count: 64, repeatedValue: Character("0")))
    }
}

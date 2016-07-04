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
    
    func splitByInitialLetter(first: String, second: String) -> Bool {
        let firstInitial = String(first.characters.first)
        let secondInitial = String(second.characters.first)
        let comparison =  firstInitial.caseInsensitiveCompare(secondInitial)
        return comparison != .OrderedSame
    }

    func testEmpty() {
        let array = [String]()
        let result = array.sectionsSplitBy(alwaysSplitPredicate)
        let expected = [String]()
        XCTAssertEqual(result, expected)
    }
    
    func testOne() {
        let array = ["Alice"]
        let result = array.sectionsSplitBy(splitByInitialLetter)
        let expected = [["Alice"]]
        XCTAssertEqual(result, expected)
    }

    func testTwo() {
        let array = ["Alice", "Bob"]
        let result = array.sectionsSplitBy(splitByInitialLetter)
        let expected = [["Alice"], ["Bob"]]
        XCTAssertEqual(result, expected)
    }
    
    func testTwoSameSection() {
        let array = ["Alice", "Andrew"]
        let result = array.sectionsSplitBy(splitByInitialLetter)
        let expected = [["Alice", "Andrew"]]
        XCTAssertEqual(result, expected)
    }
    
    func testTwoSameSectionCaseInsensitive() {
        let array = ["Alice", "andrew"]
        let result = array.sectionsSplitBy(splitByInitialLetter)
        let expected = [["Alice", "andrew"]]
        XCTAssertEqual(result, expected)
    }
    
    func testThree() {
        let array = ["Alice", "Bob", "Carol"]
        let result = array.sectionsSplitBy(splitByInitialLetter)
        let expected = [["Alice"], ["Bob"], ["Carol"]]
        XCTAssertEqual(result, expected)
    }
    
    func testLastTwoSame() {
        let array = ["Alice", "Bob", "Carol", "Charlie"]
        let result = array.sectionsSplitBy(splitByInitialLetter)
        let expected = [["Alice"], ["Bob"], ["Carol", "Charlie"]]
        XCTAssertEqual(result, expected)
    }
}

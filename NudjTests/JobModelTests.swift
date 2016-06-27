//
//  JobModelTests.swift
//  Nudj
//
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import XCTest
@testable import Nudj

class JobModelTests: XCTestCase {
    var locale: NSLocale = NSLocale.systemLocale()
    
    func jobFromComponents(currencyCode: String) -> JobModel {
        let result = JobModel(title: "test title", description: "test desc", salaryFreeText: "test salary", company: "test company", location: "test location", bonusAmount: 42, bonusCurrency: currencyCode, active: true, skills: ["test skill"], locale: locale)
        return result
    }
    
    func testInitFromComponents() {
        let job = jobFromComponents("USD")
        XCTAssertEqual(job.title, "test title")
        XCTAssertEqual(job.description, "test desc")
        XCTAssertEqual(job.salaryFreeText, "test salary")
        XCTAssertEqual(job.company, "test company")
        XCTAssertEqual(job.location, "test location")
        XCTAssertEqual(job.bonusAmount, 42)
        XCTAssertEqual(job.bonusCurrency, "USD")
        XCTAssertEqual(job.active, true)
        XCTAssertEqual(job.skills, ["test skill"])
        XCTAssertEqual(job.formattedBonus, "US$ 42") // NB non-breaking space here
    }
    
    func testGBP() {
        let job = jobFromComponents("GBP")
        XCTAssertEqual(job.formattedBonus, "£ 42") // NB non-breaking space here
    }
    
    func testEUR() {
        let job = jobFromComponents("EUR")
        XCTAssertEqual(job.formattedBonus, "€ 42") // NB non-breaking space here
    }
    
    func testNonsenseCurrency() {
        let job = jobFromComponents("Foo")
        XCTAssertEqual(job.formattedBonus, "Foo 42") // NB non-breaking space here
    }
    
}

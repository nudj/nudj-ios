//
//  JobModelTests.swift
//  Nudj
//
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import XCTest
import SwiftyJSON
@testable import Nudj

class JobModelTests: XCTestCase {
    let locale: NSLocale = NSLocale.systemLocale()
    let expectedParams: [String: AnyObject] = [
        "title": "test title",
        "description": "test desc",
        "salary": "test salary",
        "company": "test company",
        "location": "test location",
        "bonus": 42,
        "bonus_currency": "Foo",
        "active": 1,
        "skills": ["test skill"]
    ]
    
    private func jobWithCurrrency(currencyCode: String, active: Bool = true) -> JobModel {
        let result = JobModel(title: "test title", description: "test desc", salaryFreeText: "test salary", company: "test company", location: "test location", bonusAmount: 42, bonusCurrency: currencyCode, active: active, skills: ["test skill"], locale: locale)
        return result
    }
    
    private func assertIsCannedData(job: JobModel) {
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
    
    private func assertSameParams(params: [String: AnyObject], expectedParams: [String: AnyObject]) {
        // sadly we cannot do an Equatable test here where the value type is AnyObject
        XCTAssertEqual(params.count, expectedParams.count)
        for key in expectedParams.keys {
            let lhs = expectedParams[key]
            let rhs = params[key]
            XCTAssertTrue(lhs?.isEqual(rhs) ?? false, "\(lhs) != \(rhs)")
        }
    }
    
    func testInitFromComponents() {
        let job = jobWithCurrrency("USD")
        assertIsCannedData(job)
    }
    
    func testInitFromJSON() {
        let json = JSON(expectedParams)
        let job = JobModel(json: json, locale: locale)
        XCTAssertEqual(job.formattedBonus, "Foo 42") // NB non-breaking space here
    }
    
    func testGBP() {
        let job = jobWithCurrrency("GBP")
        XCTAssertEqual(job.formattedBonus, "£ 42") // NB non-breaking space here
    }
    
    func testEUR() {
        let job = jobWithCurrrency("EUR")
        XCTAssertEqual(job.formattedBonus, "€ 42") // NB non-breaking space here
    }
    
    func testNonsenseCurrency() {
        let job = jobWithCurrrency("Foo")
        XCTAssertEqual(job.formattedBonus, "Foo 42") // NB non-breaking space here
    }
    
    func testParamsForActiveJob() {
        let job = jobWithCurrrency("Foo")
        let params = job.params()
        
        assertSameParams(params, expectedParams: expectedParams)
    }
    
    func testParamsForInactiveJob() {
        let job = jobWithCurrrency("Foo", active: false)
        let params = job.params()
        var expectedParams = self.expectedParams
        expectedParams["active"] = 0        
        assertSameParams(params, expectedParams: expectedParams)
    }
}

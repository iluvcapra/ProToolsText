//
//  ADRLineTests.swift
//  PKitTests
//
//  Created by Jamie Hardt on 1/28/18.
//

import XCTest

class ADRLineTests: XCTestCase {

    var lines : [ADRLine] = []

    override func setUp() {
        super.setUp()
        
        let line1 = ADRLine(title: "Test Project",
                            supervisor: nil,
                            client: nil,
                            cueNumber: "A001",
                            scene: nil,
                            reel: nil,
                            version: nil,
                            dialogue: nil,
                            characterName: nil,
                            actorName: nil,
                            timeBudget: nil,
                            priority: nil,
                            start: "01:00:00:00",
                            finish: "01:00:01:00",
                            reason: "Test Reason",
                            note: nil,
                            shootDate: nil,
                            isEffort: false,
                            isTV: false,
                            isTBW: false,
                            isOmitted: false)
        
        var line2 = line1
        line2.start = "02:00:00:00"
        line2.finish = "02:10:00:00"
        
        var line3 = line2
        line3.cueNumber = "A002"
        
        lines = [line1, line2, line3]
        
        
    }
    
    func testValidateUniqueCueNumber() {
        let failues = lines.validateADRLines()
    }

}

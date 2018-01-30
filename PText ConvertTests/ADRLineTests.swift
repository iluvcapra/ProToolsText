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
                            isOmitted: false, userData: [:])
        
        var line2 = line1
        line2.start = "02:00:00:00"
        line2.finish = "02:10:00:00"
        
        var line3 = line2
        line3.cueNumber = "A002"
        
        lines = [line1, line2, line3]
        
        
    }
    
    func testValidateUniqueCueNumber() {
        let failues = lines.validateADRLines()
        XCTAssertTrue(failues.count == 2)
        XCTAssertTrue(failues[0].element == 0)
        XCTAssertTrue(failues[1].element == 1)
    }
    
    func testCreateFromDictionary() {
        let testInput = ["title" : "Da Project",
                         "super" : "Diego",
                         "client" : "MGM",
                         "reel" : "1",
                         "v" : "1",
                         "P":"2",
                         "Qn" : "A1001",
                         "Act" : "Olivia DeHavilland",
                         "Sc" : "1 Main Titles",
                         "mpl" : "8",
                         "note" : "Added line",
                         PTClipName : "Fuck that O'Hara cunt!!",
                         "TV" : "TV",
                         "EFF" : "",
                         "R" : "Broadcast cover",
                         PTTrackName : "Melanie"
        ]
        
        let testOutput = ADRLine.with(dictionary: testInput)
        
        XCTAssertEqual(testOutput.title, "Da Project")
        XCTAssertEqual(testOutput.supervisor, "Diego")
        XCTAssertEqual(testOutput.client, "MGM")
        XCTAssertEqual(testOutput.reel, "1")
        XCTAssertEqual(testOutput.version, "1")
        XCTAssertEqual(testOutput.priority, 2)
        XCTAssertEqual(testOutput.cueNumber, "A1001")
    }

}

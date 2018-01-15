//
//  ClipRecordTests.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 1/14/18.
//

import XCTest
@testable import PText_Convert

class ClipRecordTests: XCTestCase {

    func testCanonicalFieldApplication() {

        var t = ClipRecord(sessionName: "Session $R=1",
                           trackName: "This Track {CharName=Jamie}", trackComment:"{MPL=10}",
                           eventNumber: 1, clipName: "Test clip [N] {Note=Loud} $R=2",
                           start: "100",
                           finish: "150", muted: false, userData: [:])
        
    
        t.applyFieldsCanonically()
        
        XCTAssertEqual(t.sessionName, "Session")
        XCTAssertEqual(t.trackName, "This Track")
        XCTAssertEqual(t.clipName, "Test clip")
        
        XCTAssertEqual(t.userData["R"], "2")
        XCTAssertEqual(t.userData["CharName"], "Jamie")
        XCTAssertEqual(t.userData["N"], "N")
        XCTAssertEqual(t.userData["Note"], "Loud")
    }

    
    func testAppended() {
        var t1 = ClipRecord(sessionName: "Session $R=1",
                           trackName: "This Track {CharName=Jamie}", trackComment:"{MPL=10}",
                           eventNumber: 1, clipName: "Test clip [N] {Note=Loud} $R=2",
                           start: "100",
                           finish: "150", muted: false, userData: [:])
        t1.applyFieldsCanonically()
        
        var t2 = ClipRecord(sessionName: "Session $R=1",
                  trackName: "This Track {CharName=Jamie}", trackComment:"{MPL=10}",
                  eventNumber: 1, clipName: "More Test",
                  start: "100",
                  finish: "150", muted: false, userData: [:])
        t2.applyFieldsCanonically()
        
        let result = t1.appended(clipRecord: t2)
        
        XCTAssertEqual(result.clipName, "Test clip More Test")
    }

}

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
                           finish: "150",
                           duration: "50", muted: false, userData: [:])
        
    
        t.applyFieldsCanonically()
        
        XCTAssertEqual(t.sessionName, "Session")
        XCTAssertEqual(t.trackName, "This Track")
        XCTAssertEqual(t.clipName, "Test clip")
        
        XCTAssertEqual(t.userData["R"], "2")
        XCTAssertEqual(t.userData["CharName"], "Jamie")
        XCTAssertEqual(t.userData["N"], "N")
        XCTAssertEqual(t.userData["Note"], "Loud")
        
    }


}

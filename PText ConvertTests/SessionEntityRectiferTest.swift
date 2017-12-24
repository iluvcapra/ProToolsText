//
//  SessionEntityRectiferTest.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 12/24/17.
//

import XCTest

class RectifierTestDelegate : SessionEntityRectifierDelegate {
    
    var records = [[String:String]]()
    
    func rectifier(_ r: SessionEntityRectifier, didReadRecord : [String:String]) {
        records.append(didReadRecord)
    }
}

class SessionEntityRectiferTest: XCTestCase {
    
    var session : PTEntityParser.SessionEntity?
    var testTrack : PTEntityParser.TrackEntity?
    
    override func setUp() {
        
        session = PTEntityParser.SessionEntity.init(rawTitle: "Test Session")
        
        let testClips = [
            PTEntityParser.ClipEntity(rawName: "Test 1 $A=1 {B=Hello}",
                                      eventNumber: 1, rawStart: "01:00:00:00", rawFinish: "01:00:01:00",
                                      rawDuration: "00:00:01:00", muted: false),
            PTEntityParser.ClipEntity(rawName: "Test 2 $A=2",
                                      eventNumber: 2, rawStart: "01:00:03:10", rawFinish: "01:00:04:10",
                                      rawDuration: "00:00:01:00", muted: false),
            ] 
        
        testTrack = PTEntityParser.TrackEntity(rawTitle: "Track 1 [D]", rawComment: "This is a track {B=Goodbye} {C=Z1}", clips: testClips)
    }
    
    func testBasicClips() {

        let r = SessionEntityRectifier(tracks: [testTrack!], markers: [], session: session!)
        let d = RectifierTestDelegate()
        r.delegate = d
        
        r.interpetRecords()
        
        XCTAssertTrue(d.records.count == 2)
        XCTAssertEqual(d.records[0]["ClipName"],"Test 1")
        XCTAssertEqual(d.records[0]["Start"],"01:00:00:00")
        XCTAssertEqual(d.records[0]["TrackName"],"Track 1")
        XCTAssertEqual(d.records[1]["TrackName"],"Track 1")
        XCTAssertEqual(d.records[1]["TrackName"],"Track 1")
        XCTAssertEqual(d.records[1]["EventNumber"],"2")
    }
    
    /*
     This tests that fields set on track names copy to clips, but that fields on clips prevail.
     */
    func testTaggedClips() {

        let r = SessionEntityRectifier(tracks: [testTrack!], markers: [], session: session!)
        let d = RectifierTestDelegate()
        r.delegate = d
        
        r.interpetRecords()
        
        XCTAssertTrue(d.records.count == 2)
        XCTAssertEqual(d.records[0]["A"], "1")
        XCTAssertEqual(d.records[0]["B"], "Hello")
        XCTAssertEqual(d.records[0]["C"], "Z1")
        XCTAssertEqual(d.records[0]["D"], "D")
        
        XCTAssertEqual(d.records[1]["A"], "2")
        XCTAssertEqual(d.records[1]["B"], "Goodbye")
        XCTAssertEqual(d.records[1]["C"], "Z1")
        XCTAssertEqual(d.records[1]["D"], "D")
    }
    
    func testSessionTags() {

        let r = SessionEntityRectifier(tracks: [testTrack!], markers: [], session: session!)
        let d = RectifierTestDelegate()
        r.delegate = d
        
        r.interpetRecords()
    }

}

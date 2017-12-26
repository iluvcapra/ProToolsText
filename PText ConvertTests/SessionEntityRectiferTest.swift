//
//  SessionEntityRectiferTest.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 12/24/17.
//

import XCTest

class RectifierTestDelegate : SessionEntityTabulatorDelegate {
    
    var records = [[String:String]]()
    
    func rectifier(_ r: SessionEntityTabulator, didReadRecord : [String:String]) {
        records.append(didReadRecord)
    }
}

class SessionEntityRectiferTest: XCTestCase {
    
    var tabulator : SessionEntityTabulator?
    var testDelegate : RectifierTestDelegate?
    
    override func setUp() {
        
        let session = PTEntityParser.SessionEntity.init(rawTitle: "Test Session {S=Bill Hart}")
        
        let testClipsTrack1 = [
            PTEntityParser.ClipEntity(rawName: "Test 1 $A=1 {B=Hello}",
                                      eventNumber: 1, rawStart: "01:00:00:00", rawFinish: "01:00:01:00",
                                      rawDuration: "00:00:01:00", muted: false),
            PTEntityParser.ClipEntity(rawName: "@ {Sc=12 Int. House}",
                                      eventNumber: 2, rawStart: "01:00:00:00", rawFinish: "01:00:01:00",
                                      rawDuration: "00:00:01:00", muted: false),
            PTEntityParser.ClipEntity(rawName: "Test 2 $A=2",
                                      eventNumber: 3, rawStart: "01:00:03:10", rawFinish: "01:00:04:10",
                                      rawDuration: "00:00:01:00", muted: true),
            ]
        
        let testMarkers = [PTEntityParser.MarkerEntity(rawName: "Marker 1 [M1]",
                                                   rawComment: "[MM]",
                                                   rawLocation: "01:00:01:01"),
                       PTEntityParser.MarkerEntity(rawName: "Marker 2 [M3]",
                                                   rawComment: "",
                                                   rawLocation: "01:00:10:01")
        ]
        
        let testTracks = [
            PTEntityParser.TrackEntity(rawTitle: "Track 1 [D]", rawComment: "This is a track {B=Goodbye} {C=Z1}", clips: testClipsTrack1)
        ]
        
        tabulator = SessionEntityTabulator(tracks: testTracks, markers: testMarkers, session: session)
        testDelegate = RectifierTestDelegate()
        tabulator?.delegate = testDelegate
        tabulator?.interpetRecords()
    }
    
    func testBasicClips() {

        XCTAssertTrue(testDelegate!.records.count == 2)
        XCTAssertEqual(testDelegate!.records[0][PTClipName],"Test 1")
        XCTAssertEqual(testDelegate!.records[0][PTStart],"01:00:00:00")
        XCTAssertEqual(testDelegate!.records[0][PTTrackName],"Track 1")
        XCTAssertEqual(testDelegate!.records[1][PTTrackName],"Track 1")
        XCTAssertEqual(testDelegate!.records[1][PTTrackName],"Track 1")
        XCTAssertEqual(testDelegate!.records[1][PTEventNumber],"3")
        XCTAssertEqual(testDelegate!.records[0][PTMuted],"")
        XCTAssertEqual(testDelegate!.records[1][PTMuted],PTMuted)
    }
    
    /*
     This tests that fields set on track names copy to clips, but that fields on clips prevail.
     */
    func testTaggedClips() {
        
        XCTAssertTrue(testDelegate!.records.count >= 2)
        XCTAssertEqual(testDelegate!.records[0]["A"], "1")
        XCTAssertEqual(testDelegate!.records[0]["B"], "Hello")
        XCTAssertEqual(testDelegate!.records[0]["C"], "Z1")
        XCTAssertEqual(testDelegate!.records[0]["D"], "D")
        
        XCTAssertEqual(testDelegate!.records[1]["A"], "2")
        XCTAssertEqual(testDelegate!.records[1]["B"], "Goodbye")
        XCTAssertEqual(testDelegate!.records[1]["C"], "Z1")
        XCTAssertEqual(testDelegate!.records[1]["D"], "D")
    }
    
    func testSessionTags() {

        XCTAssertTrue(testDelegate!.records.count >= 2)
        XCTAssertEqual(testDelegate!.records[0][PTSessionName], "Test Session")
        XCTAssertEqual(testDelegate!.records[1][PTSessionName], "Test Session")
        XCTAssertEqual(testDelegate!.records[0][PTRawSessionName], "Test Session {S=Bill Hart}")

        XCTAssertEqual(testDelegate!.records[0]["S"], "Bill Hart")
        XCTAssertEqual(testDelegate!.records[1]["S"], "Bill Hart")
    }

    func testMarkerTags() {

        XCTAssertTrue(testDelegate!.records.count >= 2)
        XCTAssertNil(testDelegate!.records[0]["M1"])
        XCTAssertNil(testDelegate!.records[0]["MM"])
        XCTAssertEqual(testDelegate!.records[1]["M1"] , "M1")
        XCTAssertEqual(testDelegate!.records[1]["MM"] , "MM")
        
        XCTAssertNil(testDelegate!.records[0]["M3"])
        XCTAssertNil(testDelegate!.records[1]["M3"])
    }
    
    func testTimespanTags() {

    }
}

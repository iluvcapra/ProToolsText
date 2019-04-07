//
//  SessionEntityTests.swift
//  PKitTests
//
//  Created by Jamie Hardt on 4/7/19.
//

import XCTest
import CoreMedia

class SessionEntityTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodeTimecode() {

        let e = SessionEntity(rawTitle: "Test Session", sampleRate: 48000.0, bitDepth: "24 bit", startTime: "01:00:00:00",
                              timecodeFormat: "30 Frame", trackCount: 1, clipCount: 1, filesCount: 1)
        
        let result1 = try! e.decodeTime(from: "01:00:00:00")
        XCTAssertEqual(result1, CMTime(value: 3600, timescale: 1) )
        
        let result2 = try! e.decodeTime(from: "02:00:00:00")
        XCTAssertEqual(result2, CMTime(value: 7200, timescale: 1) )
        

        
    }
    
    func testDecodeTimecode2398() {
        let e = SessionEntity(rawTitle: "Test Session", sampleRate: 48000.0, bitDepth: "24 bit", startTime: "01:00:00:00",
                               timecodeFormat: "23.976 Frame", trackCount: 1, clipCount: 1, filesCount: 1)
        
        let result1 =  try! e.decodeTime(from: "01:00:00:00")
        XCTAssertEqual(result1, CMTime(value: 3600 * 1001, timescale: 1000) )
        
        let result2 =  try! e.decodeTime(from: "02:00:00:00")
        XCTAssertEqual(result2, CMTime(value: 7200 * 1001, timescale: 1000) )
    }


}

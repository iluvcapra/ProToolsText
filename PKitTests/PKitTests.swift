//
//  PKitTests.swift
//  PKitTests
//
//  Created by Jamie Hardt on 12/17/17.
//

import XCTest
@testable import PKit

class PKitTests: XCTestCase {
    
    private class ParserDelegateMock : PTTextFileParserDelegate {
        
        var title : String?
        var sampleRate : Double?
        var bitDepth : String?
        var startTime : String?
        var timecodeFormat : String?
        var trackCount : Int?
        var clipsCount : Int?
        var filesCount : Int?
        
        var didBegin = false
        var didFinish = false
        
        func parserWillBegin(_ parser : PTTextFileParser) {
            didBegin = true
        }
        
        func parserDidFinish(_ parser : PTTextFileParser) {
            didFinish = true
        }
        
        func parser(_ p: PTTextFileParser,
                    didReadSessionHeaderWithTitle t: String,
                    sampleRate sr: Double,
                    bitDepth bd: String,
                    startTime st: String,
                    timecodeFormat tf: String,
                    trackCount tc: Int,
                    clipsCount cc: Int,
                    filesCount fc: Int) {
            title = t
            sampleRate = sr
            bitDepth = bd
            startTime = st
            timecodeFormat = tf
            trackCount = tc
            clipsCount = cc
            filesCount = fc
        }
    
        func parser(_ parser : PTTextFileParser,
                    willReadEventsForTrack trackName: String,
                    comments: String?,
                    userDelay: String,
                    stateFlags: [String],
                    plugins: [String]) {
            
        }
        
        
        
    }

    
    func testExample1() {
        let testURL = URL(fileURLWithPath: "/Users/jamiehardt/src/ADR Spotting/PKitTests/ADR Spotting test.txt")
        
        let p = PTTextFileParser()
        let d = ParserDelegateMock()
        p.delegate = d
        
        let data = try! Data.init(contentsOf: testURL)

        XCTAssertFalse(d.didBegin)
        XCTAssertFalse(d.didFinish)
        XCTAssertNoThrow(try p.parse(data: data,
                                     encoding: String.Encoding.utf8.rawValue) )
        XCTAssertTrue(d.didBegin)
        XCTAssertTrue(d.didFinish)
        
        XCTAssertEqual(d.title, "ADR Spotting test")
        XCTAssertEqual(d.sampleRate, 48000.0)
        XCTAssertEqual(d.bitDepth, "24-bit")
        XCTAssertEqual(d.startTime, "00:59:52:00.00")
        XCTAssertEqual(d.timecodeFormat, "23.976 Frame")
        XCTAssertEqual(d.trackCount, 5)
        XCTAssertEqual(d.clipsCount, 2)
        XCTAssertEqual(d.filesCount, 2)
        
    }

    func testExample2() {
        let testURL = URL(fileURLWithPath: "/Users/jamiehardt/src/ADR Spotting/PKitTests/PT Text Export.txt")
        
        let p = PTTextFileParser()
        let d = ParserDelegateMock()
        p.delegate = d
        
        let data = try! Data.init(contentsOf: testURL)
        
        XCTAssertFalse(d.didBegin)
        XCTAssertFalse(d.didFinish)
        XCTAssertNoThrow(try p.parse(data: data,
                                     encoding: String.Encoding.utf8.rawValue) )
        XCTAssertTrue(d.didBegin)
        XCTAssertTrue(d.didFinish)
        
        XCTAssertEqual(d.title, "ADR Spotting test")
        XCTAssertEqual(d.sampleRate, 48000.0)
        XCTAssertEqual(d.bitDepth, "24-bit")
        XCTAssertEqual(d.startTime, "00:59:52:00")
        XCTAssertEqual(d.timecodeFormat, "23.976 Frame")
        XCTAssertEqual(d.trackCount, 4)
        XCTAssertEqual(d.clipsCount, 0)
        XCTAssertEqual(d.filesCount, 0)
        
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}

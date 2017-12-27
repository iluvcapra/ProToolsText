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
        
        var tracks : [Dictionary<String,Any>] = []
        
        var clips : [Dictionary<String,Any>] = []
        
        var markers : [Dictionary<String,Any>] = []
        
        func parserWillBegin(_ parser : PTTextFileParser) {
            didBegin = true
            XCTAssertFalse(didFinish)
        }
        
        func parserDidFinish(_ parser : PTTextFileParser) {
            XCTAssertTrue(didBegin)
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
            
            XCTAssertTrue(didBegin)
            XCTAssertFalse(didFinish)
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
            XCTAssertNotNil(title)
            
            var trackDict = Dictionary<String,Any>()
            
            trackDict["name"] = trackName
            trackDict["comments"] = comments
            trackDict["userDelay"] = userDelay
            trackDict["stateFlags"] = stateFlags
            trackDict["plugins"] =  plugins
            
            tracks.append(trackDict)
        }
        
        func parser(_ parser: PTTextFileParser,
                    didReadEventNamed name: String,
                    channel: Int,
                    eventNumber: Int,
                    start : String,
                    end : String,
                    duration : String,
                    timestamp : String?,
                    state: String) {
            let clip : [String : Any] = ["name" : name, "channel" : channel,
                                         "eventNumber" : eventNumber,
                "start": start, "end": end, "duration": duration, "state": state]
            
            clips.append(clip)
        }
        
        func parser(_ parser : PTTextFileParser,
                    didReadMemoryLocation loc: Int,
                    atLocation: String,
                    timeReference: Int,
                    units: String,
                    name: String,
                    comments: String?) {
            
            let marker : [String:Any] = ["location" : loc,
                          "at" : atLocation,
                          "timeReference" : timeReference,
                          "units" : units,
                          "name" : name]
            
            markers.append(marker)
            
        }
        
        func parserDidFinishReadingTrack(_ parser : PTTextFileParser) {

        }
        
        
    }
    
    func testExample1() {
        let testURL = Bundle(for: PKitTests.self).url(forResource: "ADR Spotting test", withExtension: "txt")!
        
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
        
        XCTAssertEqual(d.tracks.count, 5)
        
        XCTAssertEqual(d.tracks[0]["name"] as! String, "Jamie")
        XCTAssertNotEqual(d.tracks[0]["comments"] as! String, "Jamie Comments")
        XCTAssertEqual(d.tracks[0]["comments"] as! String, "Jamie comments")
        XCTAssertEqual(d.tracks[4]["plugins"] as! [String],
                        ["AIR Non-Linear Reverb (stereo)","Channel Strip (stereo)"])
        
        XCTAssertNil(d.tracks[2]["comments"] as? String)
        
        XCTAssertEqual(d.clips.count, 8)
        
        XCTAssertEqual(d.markers.count, 2)
    }

    func testExample2() {
        let testURL = Bundle(for: PKitTests.self).url(forResource: "PT Text Export", withExtension: "txt")!
        
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
        
        XCTAssertEqual(d.markers.count, 2)
        
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}

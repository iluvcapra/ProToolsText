//
//  TimeRepresentationTests.swift
//  PKitTests
//
//  Created by Jamie Hardt on 9/26/18.
//

import XCTest

class TimeRepresentationTests: XCTestCase {

    let feet = "33+08.58"
    let tc = "01:00:41:29.52"
    let tcdf = "01:00:41;28"
    let ms = "0:40.448"
    let samples = "1351680"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        XCTAssert(  TimeRepresentation.footage.detect(in: feet) )
        XCTAssert(  TimeRepresentation.timecode.detect(in: tc) )
        XCTAssert(  TimeRepresentation.timecodeDF.detect(in: tcdf) )
        XCTAssert(  TimeRepresentation.realtime.detect(in: ms ) )
        XCTAssert( !TimeRepresentation.timecodeDF.detect(in: tc) )
        XCTAssert(  TimeRepresentation.samples.detect(in: samples ) )
        XCTAssert( !TimeRepresentation.realtime.detect(in: samples) )
    }
    
    func testTerms() {
        let (format_ff, terms_ff) = TimeRepresentation.terms(in: feet)!
        XCTAssertEqual(format_ff, TimeRepresentation.footage)
        XCTAssertEqual(terms_ff, ["33","08",".58"])

        let (format_tc, terms_tc) = TimeRepresentation.terms(in: tc)!
        XCTAssertEqual(format_tc, TimeRepresentation.timecode)
        XCTAssertEqual(terms_tc, ["01","00","41","29",".52"])
        
        let (format_tcdf, terms_tcdf) = TimeRepresentation.terms(in: tcdf)!
        XCTAssertEqual(format_tcdf, TimeRepresentation.timecodeDF)
        XCTAssertEqual(terms_tcdf, ["01","00","41","28", nil])

    }
    
}

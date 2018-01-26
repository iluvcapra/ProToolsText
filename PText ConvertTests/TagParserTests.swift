//
//  PText_ConvertTests.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 12/23/17.
//

import XCTest
@testable import PText_Convert

class PText_ConvertTests: XCTestCase {
    
    func testExample() {
        let tp = TagParser(string: "this is a test [A] [B] {Sc=23 Int. House}")
        let result = tp.parse()
        
        XCTAssertTrue(result.fields.keys.contains("A"))
        XCTAssertTrue(result.fields.keys.contains("B"))
        XCTAssertTrue(result.fields.keys.contains("Sc"))
        
        XCTAssertEqual(result.fields["A"], "A")
        XCTAssertEqual(result.fields["B"], "B")
        XCTAssertEqual(result.text, "this is a test")
        XCTAssertEqual(result.fields["Sc"], "23 Int. House")
    }
    
    func testAbutting() {
        let tp = TagParser(string: "this is a name with [A][B]{note=a note}")
        let result = tp.parse()
        
        XCTAssertEqual(result.fields["A"],"A" )
        XCTAssertEqual(result.fields["B"],"B" )
        XCTAssertEqual(result.fields["note"],"a note" )
    }
    
    func testPTJunk() {
        let tp = TagParser(string: "this is a -01 [TEST] {X=hello world}-03")
        let result = tp.parse()
        
        XCTAssertEqual(result.fields["TEST"], "TEST")
        XCTAssertEqual(result.fields["X"], "hello world")
        XCTAssertEqual(result.text, "this is a -01")
    }
    
    func testDollar() {
        let tp = TagParser(string: "this is some text $V=100 $X=HELLO $QN=1001")
        let result = tp.parse()
        
        XCTAssertTrue(result.fields.keys.contains("V"))
        XCTAssertTrue(result.fields.keys.contains("X"))
        XCTAssertTrue(result.fields.keys.contains("QN"))
        
        XCTAssertEqual(result.text, "this is some text")
        XCTAssertEqual(result.fields["V"], "100")
        XCTAssertEqual(result.fields["X"], "HELLO")
        XCTAssertEqual(result.fields["QN"], "1001")
    }
    
    func testChars() {
        let tp = TagParser(string: "\"This is a line– and some more after a pause...\" (sotto) [TBW] [OMIT] {Char=Bill Wilson}")
        let result = tp.parse()
        
        XCTAssertTrue(result.fields.keys.contains("TBW"))
        XCTAssertTrue(result.fields.keys.contains("OMIT"))
        XCTAssertTrue(result.fields.keys.contains("Char"))
        
        XCTAssertEqual(result.text, "\"This is a line– and some more after a pause...\" (sotto)")
        XCTAssertEqual(result.fields["TBW"], "TBW")
        XCTAssertEqual(result.fields["OMIT"], "OMIT")
        XCTAssertEqual(result.fields["Char"], "Bill Wilson")
    }

}

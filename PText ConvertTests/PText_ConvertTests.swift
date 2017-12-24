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
        
        XCTAssertTrue(result.keys.contains("A"))
        XCTAssertTrue(result.keys.contains("B"))
        XCTAssertTrue(result.keys.contains("_name"))
        XCTAssertTrue(result.keys.contains("Sc"))
        
        XCTAssertEqual(result["A"], "A")
        XCTAssertEqual(result["B"], "B")
        XCTAssertEqual(result["_name"], "this is a test")
        XCTAssertEqual(result["Sc"], "23 Int. House")
    }
    
    func testDollar() {
        let tp = TagParser(string: "this is some text $V=100 $X=HELLO $QN=1001")
        let result = tp.parse()
        
        XCTAssertTrue(result.keys.contains("_name"))
        XCTAssertTrue(result.keys.contains("V"))
        XCTAssertTrue(result.keys.contains("X"))
        XCTAssertTrue(result.keys.contains("QN"))
        
        XCTAssertEqual(result["_name"], "this is some text")
        XCTAssertEqual(result["V"], "100")
        XCTAssertEqual(result["X"], "HELLO")
        XCTAssertEqual(result["QN"], "1001")
    }
    
    func testChars() {
        let tp = TagParser(string: "\"This is a line– and some more after a pause...\" (sotto) [TBW] [OMIT] {Char=Bill Wilson}")
        let result = tp.parse()
        
        XCTAssertTrue(result.keys.contains("_name"))
        XCTAssertTrue(result.keys.contains("TBW"))
        XCTAssertTrue(result.keys.contains("OMIT"))
        XCTAssertTrue(result.keys.contains("Char"))
        
        XCTAssertEqual(result["_name"], "\"This is a line– and some more after a pause...\" (sotto)")
        XCTAssertEqual(result["TBW"], "TBW")
        XCTAssertEqual(result["OMIT"], "OMIT")
        XCTAssertEqual(result["Char"], "Bill Wilson")
    }

}

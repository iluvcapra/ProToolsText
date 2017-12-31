//
//  JHScannerTests.swift
//  PKitTests
//
//  Created by Jamie Hardt on 12/30/17.
//

import XCTest

class JHScannerTests: XCTestCase {

    func testScannerAccept() {
        
        let s = JHScanner(scalars: "test string".unicodeScalars)
        XCTAssertTrue(s.accept(scalar: Unicode.Scalar(0x74) ) )
        XCTAssertTrue(s.accept(scalar: Unicode.Scalar(0x65) ) )
        XCTAssertTrue(s.accept(scalar: Unicode.Scalar(0x73) ) )
        XCTAssertTrue(s.accept(scalar: Unicode.Scalar(0x74) ) )
        XCTAssertTrue(s.accept(string: " "))
        XCTAssertFalse(s.accept(string: "blarg"))
        XCTAssertTrue(s.accept(string: "str"))
        XCTAssertFalse(s.accept(scalar: Unicode.Scalar(0x20)) )
        XCTAssertTrue(s.accept(string: "ing"))
        XCTAssertTrue(s.atEnd)
    }
    
    func testScannerExpect() {
        let s = JHScanner(scalars: "01 02 fire 03 % bank 😀".unicodeScalars)
        XCTAssertNoThrow(try s.expect(string: "01"))
        XCTAssertNoThrow(try s.expect(scalar: Unicode.Scalar(0x20)))
        XCTAssertNoThrow(try s.expect(string: "02"))
        XCTAssertNoThrow(try s.expect(string: " "))
        XCTAssertThrowsError(try s.expect(string: "03"), "") { (e : Error) in
            guard let er = e as? JHScanner<String.UnicodeScalarView>.ExpectFailedError else {
                XCTFail("Did not return proper error")
                return
            }
            XCTAssertEqual(er.offset, 6)
            XCTAssertEqual(er.expected, "03")
        }
        
        XCTAssertNoThrow(try s.expect(string: "fire"))
        XCTAssertNoThrow(try s.expect(string: " 03 % bank "))
        XCTAssertNoThrow(try s.expect(string: "😀"))
        XCTAssertThrowsError(try s.expectMore())
        XCTAssertThrowsError(try s.expect(string: "wompa"), "") { (e: Error) in
            guard let _ = e as? JHScanner<String.UnicodeScalarView>.AtEndError else {
                XCTFail("Did not return proper error")
                return
            }
        }
    }
    
    func testReadWhile() {
        let s = JHScanner<String.UnicodeScalarView>(scalars: "123 Fake Street".unicodeScalars)
        do {
            let num = try s.readUpTo(scalar: UnicodeScalar(0x20) )
            XCTAssertEqual(num, "123")
            try s.expect(string: " ")
            let street = try s.readWhile(characters: CharacterSet.alphanumerics)
            XCTAssertEqual(street, "Fake")
        } catch _ {
            XCTFail("")
        }
    }
    
    func testSkipWhile() {
        let s = JHScanner(scalars: "12345abc".unicodeScalars)
        XCTAssertNoThrow(try s.skipWhile(characters: CharacterSet.decimalDigits))
        let str = s.remainder
        XCTAssertEqual(String(str), "abc")
    }
    
    func testLookahead() {
        let s = JHScanner(scalars: "x[1,2]".unicodeScalars )
        let b = s.lookahead {
            try s.expect(string: "x")
            try s.expect(string: "[")
        }
        XCTAssertTrue(b)
        XCTAssertNoThrow(try s.expect(string: "1,2") )
        
        let s2 = JHScanner(scalars: "[R1]".unicodeScalars)
        let b2 = s2.lookahead {
            try s2.expect(string: "[R")
            try s2.expect(string: "A")
        }
        
        XCTAssertFalse(b2)
        XCTAssertNoThrow(try s2.expect(string: "[R1"))
    }
    
    func testRemainder() {
        let s = JHScanner<String.UnicodeScalarView>(scalars: "wonder wonder".unicodeScalars)
        XCTAssertNoThrow( try s.expect(string: "wonder") )
        let rest = s.remainder
        
        XCTAssertEqual(String(rest), " wonder")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

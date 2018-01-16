//
//  DictionaryAdditionsTests.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 1/15/18.
//

import XCTest

class DictionaryAdditionsTests: XCTestCase {

    func testSorted() {
        let t : [[String:Any]] = [
            ["A": 1 , "B": 2 , "X" : 1],
            ["A": 3 , "C": 2 , "X" : 11],
            ["B": 1 , "C": 2 , "X" : 12]
        ]
        
        XCTAssertEqual(t.collatedKeys(), ["A","B","C","X"])
        XCTAssertEqual(t.collatedValues()[0][0] as! Int?, 1 )
        XCTAssertEqual(t.collatedValues()[0][1] as! Int?, 2 )
        XCTAssertEqual(t.collatedValues()[0][2] as! Int?, nil )
        XCTAssertEqual(t.collatedValues()[0][3] as! Int?, 1 )
        
        XCTAssertEqual(t.collatedValues()[1][0] as! Int?, 3 )
        XCTAssertEqual(t.collatedValues()[1][1] as! Int?, nil )
        XCTAssertEqual(t.collatedValues()[1][2] as! Int?, 2 )
        XCTAssertEqual(t.collatedValues()[1][3] as! Int?, 11 )
        
        XCTAssertEqual(t.collatedValues()[2][0] as! Int?, nil )
        XCTAssertEqual(t.collatedValues()[2][1] as! Int?, 1 )
        XCTAssertEqual(t.collatedValues()[2][2] as! Int?, 2 )
        XCTAssertEqual(t.collatedValues()[2][3] as! Int?, 12 )
    }



}

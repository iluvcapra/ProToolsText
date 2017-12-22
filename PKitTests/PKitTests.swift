//
//  PKitTests.swift
//  PKitTests
//
//  Created by Jamie Hardt on 12/17/17.
//

import XCTest
@testable import PKit

class PKitTests: XCTestCase {
    

    
    func testExample() {
        let testURL = URL(fileURLWithPath: "/Users/jamiehardt/src/ADR Spotting/PKitTests/ADR Spotting test.txt")
        
        let p = PTTextFileParser()
        let d = try! Data.init(contentsOf: testURL)
        XCTAssertNoThrow(try p.parse(data: d, encoding: String.Encoding.utf8.rawValue) )
        
       
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}

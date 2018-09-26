//
//  NSRegularExpressionAdditions_Test.swift
//  PKitTests
//
//  Created by Jamie Hardt on 9/25/18.
//

import XCTest

class NSRegularExpressionAdditions_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let str = "1-2.3:4/5"
        do {
            let reg = try NSRegularExpression(pattern: "(\\d)-(\\d)\\.(\\d):(\\d)/(\\d)")
            
            guard let matches = reg.hasFirstMatch(in: str) else { throw NSError() }
            
            XCTAssertEqual(matches, [str,"1","2","3","4","5"], "")
            
        } catch  _ {
            XCTFail()
        }
    }
}

//
//  TimeLordTests.swift
//  TimeLordTests
//
//  Created by Jamie Hardt on 12/17/17.
//

import XCTest
import CoreMedia

@testable import TimeLord

class TimeLordTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDivide() {
        let frame24 = CMTime(value: 1, timescale: 24)
        let frame2997 = CMTime(value: 1001, timescale: 30_000)
        
        let t1 = CMTime(value: 100, timescale: 24)
        let r1 = t1.divide(by: frame24)
        XCTAssertEqual(r1, 100.0)
        
        let t2 = CMTime(value: 50, timescale: 25)
        let r2 = t2.divide(by: frame24)
        XCTAssertEqual(r2, 48.0)
        
        let t3 = CMTime(value: 31, timescale: 30)
        let r3 = t3.divide(by: frame24)
        XCTAssertEqual(r3, 24.8)
        
        let t4 = CMTime(value: 108_000, timescale: 30)
        let r4 = t4.divide(by: frame2997)
        XCTAssertGreaterThanOrEqual(r4, 107_892.0)
        XCTAssertLessThanOrEqual(r4, 107_892.2)
    }
    
}

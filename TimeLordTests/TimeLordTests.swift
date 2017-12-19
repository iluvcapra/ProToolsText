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

    func testFeetFrames() {
        let t1 = FeetFrames.from(frameCount: 16, perfsPerFrame: 4, perfsPerFoot: 64)
        XCTAssertEqual(t1.feet, 1)
        XCTAssertEqual(t1.frame, 0)
        XCTAssertEqual(t1.footFraming, 0)
        
        let t2 = FeetFrames.from(frameCount: 24, perfsPerFrame: 4, perfsPerFoot: 64)
        XCTAssertEqual(t2.feet, 1)
        XCTAssertEqual(t2.frame, 8)
        XCTAssertEqual(t2.footFraming, 0)
        
        let t3 = FeetFrames.from(frameCount: 30, perfsPerFrame: 3, perfsPerFoot: 64)
        XCTAssertEqual(t3.feet, 1)
        XCTAssertEqual(t3.frame, 8)
        XCTAssertEqual(t3.footFraming, 1)
    }
    
//    func test3perf() {
//        let frames = (0..<64).map { (i) -> FeetFrames in
//            return FeetFrames.from( frameCount: i, perfsPerFrame: 3, perfsPerFoot: 64)
//        }
//
//        XCTAssertEqual(frames.filter { $0.feet == 0}.count , 21)
//        XCTAssertEqual(frames.filter { $0.feet == 1}.count , 21)
//        XCTAssertEqual(frames.filter { $0.feet == 2}.count , 22)
//        XCTAssertEqual(frames.filter { $0.feet == 3}.count , 0)
//
//        XCTAssertTrue(frames.filter { $0.feet == 0}.map {$0.frame} == Array(0...20) )
//        XCTAssertTrue(frames.filter { $0.feet == 1}.map {$0.frame} == Array(0...20) )
//        XCTAssertTrue(frames.filter { $0.feet == 2}.map {$0.frame} == Array(0...21) )
//    }
    
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

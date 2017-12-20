//
//  FrameCountFormatter_Test.swift
//  TimeLordTests
//
//  Created by Jamie Hardt on 12/19/17.
//

import XCTest
import CoreMedia
import AVFoundation

@testable import TimeLord

class FrameCountFormatter_Test: XCTestCase {

    func testToString() {
        let f = FrameCountFormatter()
        f.showFractionalFrames = false
        f.frameDuration = CMTime(value: 1, timescale: 24)
        
        let t1 = CMTime(value: 12, timescale: 24)
        let r1 = f.string(for: t1)
        XCTAssertEqual("12", r1)
        
        f.showFractionalFrames = true
        
        let t2 = CMTime(value: 31, timescale: 30)
        let r2 = f.string(for: t2)
        XCTAssertEqual("24.8", r2)
    }
    
    func testFromString() {
        let f = FrameCountFormatter()
        
        let t1 = "86400"
        
        var timeObj : AnyObject? = nil
        var errorDesc : NSString? = nil
        let r1 = f.getObjectValue(&timeObj, for: t1, errorDescription: &errorDesc)
        
        XCTAssertTrue(r1)
        XCTAssertNil(errorDesc)
        XCTAssertNotNil(timeObj)
        XCTAssertEqual(timeObj!.timeValue, CMTime(value: 3600, timescale: 1))
        
    }



}

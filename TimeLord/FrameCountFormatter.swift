//
//  FrameCountFormatter.swift
//  TimeLord
//
//  Created by Jamie Hardt on 12/19/17.
//

import Cocoa
import CoreMedia

class FrameCountFormatter: Formatter {
    
    var showFractionalFrames : Bool = false
    
    var frameDuration : CMTime = CMTime(value: 1, timescale: 24)
    
    override func string(for obj: Any?) -> String? {
        guard let time = obj as? CMTime else {
            return nil
        }
        
        let frames = time.divide(by: frameDuration)
        
        if showFractionalFrames {
            return "\(frames)"
        } else {
            let frm = floor(frames)
            return "\(frm)"
        }
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                 for string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        let s = Scanner(string: string)
        var dval : Double = 0.0
        
        guard s.scanDouble(&dval) else {
            error?.pointee = "Failed to find number"
            return false
        }
        
        obj?.pointee = NSNumber(floatLiteral: dval)
        
        return true
    }
}

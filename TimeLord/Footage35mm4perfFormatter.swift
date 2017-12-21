//
//  Footage35mm4perfFormatter.swift
//  TimeLord
//
//  Created by Jamie Hardt on 12/19/17.
//

import Cocoa
import CoreMedia
import AVFoundation

public class Footage35mm4perfFormatter: Formatter {
    
    var frameDuration : CMTime = CMTime(value: 1, timescale: 24)
    private var showSubframes : Bool = false
    
    let framesPerFoot = 16
    var feetFramesSeparator = "+"
    
    public override func string(for obj: Any?) -> String? {
        guard let timeValObj = obj as? NSValue else {
            return nil
        }
        
        let time = timeValObj.timeValue
        let frameCount = time.divide(by: frameDuration)
        let fullFrames = Int(floor(frameCount))
        let subFrames = frameCount - Double(fullFrames)
        
        let divresult = fullFrames.quotientAndRemainder(dividingBy: framesPerFoot)
        
        if showSubframes {
            let sfScaled = floor(subFrames * 1000)
            
            return NSString(format:"%i%@%02i.%03i",
                            divresult.quotient,
                            feetFramesSeparator,
                            divresult.remainder,
                            sfScaled ) as String
        } else {
            return NSString(format:"%i%@%02i",
                            divresult.quotient,
                            feetFramesSeparator,
                            divresult.remainder ) as String
        }
    }
    
    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                               for string: String,
                               errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        return false
    }
}

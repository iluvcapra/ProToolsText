//
//  FeetFramesFormatter.swift
//  TimeLord
//
//  Created by Jamie Hardt on 12/17/17.
//

import Cocoa
import CoreMedia

/*
 #include <stdlib.h>
 
 typedef struct _FFResult {
 int feet;
 unsigned frame;
 unsigned thisFootStartsOnPerf;
 } FFResult;
 
 FFResult FeetFrames(int frameCount, unsigned perfsPerFrame, unsigned perfsPerFoot) {
 
 int   totalPerfs   = frameCount * perfsPerFrame;
 div_t feetResult   = div(totalPerfs     ,  perfsPerFoot);
 div_t framesResult = div(feetResult.rem ,  perfsPerFrame);
 
 FFResult retVal = {
 .feet = feetResult.quot,
 .frame = framesResult.quot,
 .thisFootStartsOnPerf = (perfsPerFrame - framesResult.rem) % perfsPerFrame
 };
 
 return retVal;
 }
 
 int main(int argc, const char **argv) {
 
 printf("35mm 4perf  35mm 3perf  16mm\n");
 int i;
 for (i = 0; i < 128; i++) {
 FFResult r = FeetFrames(i,4,64);
 printf("%i+%02i.%i      ",r.feet,r.frame,r.thisFootStartsOnPerf);
 
 r = FeetFrames(i,3,64);
 printf("%i+%02i.%i      ",r.feet,r.frame,r.thisFootStartsOnPerf);
 
 r = FeetFrames(i,1,40);
 printf("%i+%02i.%i\n",r.feet,r.frame,r.thisFootStartsOnPerf);
 }
 return 0;
 }
 
 */

struct FeetFrames {
    var feet : Int
    var frame : Int
    var footFraming : Int
    
    static func from(frameCount : Int, perfsPerFrame : Int, perfsPerFoot : Int) -> FeetFrames {
        
        let totalPerfs = frameCount * perfsPerFrame
        let feetResult = totalPerfs.quotientAndRemainder(dividingBy: perfsPerFoot)
        let framesResults = feetResult.remainder.quotientAndRemainder(dividingBy: perfsPerFrame)
        
        return FeetFrames(feet: feetResult.quotient,
                          frame: framesResults.quotient,
                          footFraming: (perfsPerFrame - framesResults.remainder) % perfsPerFrame )
    }
}


public extension CMTime {
    
    public func divide(by divider : CMTime) -> Double {
        
        if divider.isPositiveInfinity || divider.isNegativeInfinity {
            return 0.0
        }
        
        let scale = self.timescale * divider.timescale
        let finNum = self.convertScale(scale, method: CMTimeRoundingMethod.roundTowardZero)
        let finDiv = divider.convertScale(scale, method: CMTimeRoundingMethod.roundTowardZero)
        return Double(finNum.value) / Double(finDiv.value)
    }
}

class FeetFramesFormatter: Formatter {
    
    var fractionalFrames : Bool = false
    
    var frameDuration : CMTime = CMTime(value: 1, timescale: 24)
    
    override func string(for obj: Any?) -> String? {
        guard let time = obj as? CMTime else {
            return nil
        }
        
        if !time.isValid {
            return "(Invalid)"
        } else if time.isIndefinite {
            return "(Indefinite)"
        } else if time.isPositiveInfinity {
            return "(+∞)"
        } else if time.isNegativeInfinity {
            return "(-∞)"
        }
        
        return ""
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                 for string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

        return false
    }
}

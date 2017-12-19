//
//  CMTime_Additions.swift
//  TimeLord
//
//  Created by Jamie Hardt on 12/19/17.
//

import Foundation
import CoreMedia

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

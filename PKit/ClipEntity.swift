//
//  ClipEntity.swift
//  PKit
//
//  Created by Jamie Hardt on 4/7/19.
//

import Foundation
import CoreMedia

public struct ClipEntity {
    public let rawName : String
    public let eventNumber : Int
    public let rawStart : String
    public let rawFinish : String
    public let rawDuration : String
    public let rawUserTimestamp : String?
    public let muted : Bool
    
    public let start : CMTime
    public let finish : CMTime
    public let userTimestamp : CMTime?
    
    public var duration : CMTime {
        return finish - start
    }
    
    public init(rawName n: String, eventNumber e: Int,
                rawStart s: String,
                rawFinish f: String,
                rawDuration d: String,
                rawUserTimestamp u: String?,
                start tcStart : CMTime,
                finish tcFinish : CMTime,
                userTimestamp tcTimestamp : CMTime?,
                muted m: Bool) {
        rawName = n
        eventNumber = e
        rawStart = s
        rawFinish = f
        rawDuration = d
        rawUserTimestamp = u
        muted = m
        
        start = tcStart
        finish = tcFinish
        userTimestamp = tcTimestamp
        
    }
}

        

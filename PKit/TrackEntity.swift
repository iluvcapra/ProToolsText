//
//  TrackEntity.swift
//  PKit
//
//  Created by Jamie Hardt on 4/7/19.
//

import Foundation

public struct TrackEntity {
    public let solo : Bool
    public let mute : Bool
    public let active : Bool
    public let hidden : Bool
    public let rawTitle : String
    public let rawComment : String
    public var clips : [ClipEntity]
    
    public init(rawTitle t : String, rawComment com: String,
                solo : Bool, mute : Bool,
                active : Bool, hidden : Bool,
                clips ca : [ClipEntity]) {
        rawTitle = t
        rawComment = com
        clips  = ca
        self.solo = solo
        self.mute = mute
        self.active = active
        self.hidden = hidden
    }
}

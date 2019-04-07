//
//  SessionEntity.swift
//  PKit
//
//  Created by Jamie Hardt on 4/7/19.
//

import Foundation

public struct SessionEntity {
    public let rawTitle : String
    public let sampleRate : Double
    public let bitDepth : String
    public let startTime : String
    public let timecodeFormat : String
    public let trackCount : Int
    public let clipCount : Int
    public let filesCount : Int
    
    public init(rawTitle : String,
                sampleRate : Double,
                bitDepth : String,
                startTime : String,
                timecodeFormat : String,
                trackCount : Int,
                clipCount : Int,
                filesCount : Int) {
        self.rawTitle = rawTitle
        self.sampleRate = sampleRate
        self.bitDepth = bitDepth
        self.startTime = startTime
        self.timecodeFormat = timecodeFormat
        self.trackCount = trackCount
        self.clipCount = clipCount
        self.filesCount = filesCount
    }
}

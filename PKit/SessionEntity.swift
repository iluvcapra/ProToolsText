//
//  SessionEntity.swift
//  PKit
//
//  Created by Jamie Hardt on 4/7/19.
//

import Foundation
import CoreMedia

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
    
    enum TimecodeFormat : String {
        case Frame2398      = "23.976 Frame"
        case Frame24        = "24 Frame"
        case Frame25        = "25 Frame"
        case Frame2997      = "29.97 Frame"
        case Frame2997Drop  = "29.97 Drop Frame"
        case Frame30        = "30 Frame"
        case Frame30Drop    = "30 Drop Frame"
    }
    
    func symbolicTimecodeFormat() throws -> TimecodeFormat {
        guard let retval = TimecodeFormat(rawValue: self.timecodeFormat) else {
            throw ProToolsTimeParsingError(proposedString: self.timecodeFormat)
        }
        return retval
    }
    
    func framesPerTimecodeSecond() throws -> Int {
        switch try self.symbolicTimecodeFormat() {
        case .Frame2398, .Frame24:
            return 24
        case .Frame25:
            return 25
        case .Frame2997Drop, .Frame2997, .Frame30Drop, .Frame30:
            return 30
        }
    }
    
    var isDropFrame : Bool {
        switch self.timecodeFormat {
        case "29.97 Drop Frame":    fallthrough
        case "30 Drop Frame":       return true
        default:                    return false
        }
    }
    
    private func frameCount(for s : String) throws -> (count: Int, perSecond: Int) {
        let (rep, terms) = try TimeRepresentation.terms(in: s)
        
        let termMultiples : [Double]
        let fps : Double
        switch rep {
        case .timecode, .timecodeDF:
            fps = Double(try self.framesPerTimecodeSecond() )
            termMultiples = [3600.0, 60.0, 1.0].map { $0 * fps } + [1.0]
        case .footage:
            fps = 24.0
            termMultiples = [16.0, 1.0]
        case .samples:
            fps = self.sampleRate
            termMultiples = [fps]
        case .realtime:
            fps = Double(try self.framesPerTimecodeSecond() )
            termMultiples = [60.0 * fps, fps]
        }
        
        let numericalTerms = terms.map { Double($0 ?? "") ?? 0.0 }
        let rawFrameCount =  zip(numericalTerms, termMultiples).map {$0 * $1}.reduce(0.0,+)
        
        if rep == .timecodeDF {
            let dfCorrection = droppedFrameCount(for: Int( rawFrameCount) )
            return ( Int( rawFrameCount ) - dfCorrection , Int(fps) )
        } else {
            return ( Int( rawFrameCount ) , Int(fps) )
        }
    }
    
    func decodeTime(from string : String) throws -> CMTime {
        let (frameCount, fps) = try self.frameCount(for : string)
        
        return CMTime(value: CMTimeValue(frameCount),
                      timescale: CMTimeScale(fps))
    }
    
}

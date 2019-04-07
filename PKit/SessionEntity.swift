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
        
        var frameDuration : CMTime {
            switch self {
            case .Frame24:
                return CMTime(value: 1, timescale: 24)
            case .Frame2398:
                return CMTime(value: 1001, timescale: 24000)
            case .Frame25:
                return CMTime(value: 1, timescale: 25)
            case .Frame30: fallthrough
            case .Frame30Drop:
                return CMTime(value: 1, timescale: 30)
            case .Frame2997: fallthrough
            case .Frame2997Drop:
                return CMTime(value: 1001, timescale: 30000)
            }
        }
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
    
    private func frameCount(for s : String) throws -> (count: Int, frameDuration: CMTime) {
        let (rep, terms) = try TimeRepresentation.terms(in: s)
        
        let termMultiples : [Double]
        let frameDur : CMTime
        switch rep {
        case .timecode, .timecodeDF:
            let fpss = try self.framesPerTimecodeSecond()
            frameDur = try self.symbolicTimecodeFormat().frameDuration
            termMultiples = [3600.0, 60.0, 1.0].map { $0 * Double(fpss) } + [1.0]
        case .footage:
            frameDur = CMTime(value: 24000, timescale: 1001) // FIXME this won't be right under some circumstances
            termMultiples = [16.0, 1.0]
        case .samples:
            frameDur = CMTime(value: 1, timescale: Int32(self.sampleRate))
            termMultiples = [self.sampleRate]
        case .realtime:
            frameDur = CMTime(value: 1, timescale: 1)
            termMultiples = [60.0, 1.0]
        }
        
        let numericalTerms = terms.map { Double($0 ?? "") ?? 0.0 }
        let rawFrameCount =  zip(numericalTerms, termMultiples).map {$0 * $1}.reduce(0.0,+)
        
        if rep == .timecodeDF {
            let dfCorrection = droppedFrameCount(for: Int( rawFrameCount) )
            return ( Int( rawFrameCount ) - dfCorrection , frameDur )
        } else {
            return ( Int( rawFrameCount ) , frameDur )
        }
    }
    
    func decodeTime(from string : String) throws -> CMTime {
        let (frameCount, frameDuration) = try self.frameCount(for : string)
        
        return CMTime(value: Int64(frameCount * Int(frameDuration.value)),
                      timescale: frameDuration.timescale)
    }
    
}

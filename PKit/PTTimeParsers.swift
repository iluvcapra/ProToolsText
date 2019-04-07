//
//  PTTimeParsers.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 9/25/18.
//

import Foundation
import CoreMedia

extension NSRegularExpression {
    func hasFirstMatch(in str : String) -> [String?]? {
        guard  let tcr = self
            .firstMatch(in: str, options: [],
                        range: NSRange(location: 0, length: str.count )) else { return nil }
        
        return (0 ..< tcr.numberOfRanges).map {
            let thisRange = tcr.range(at: $0)
            
            if thisRange.length == 0 && thisRange.location == NSNotFound {
                return nil
            } else {
                let start = str.index(str.startIndex, offsetBy: thisRange.lowerBound)
                let end = str.index(start, offsetBy: thisRange.length)
                return String(str[start..<end])
            }
        }
    }
}

struct ProToolsTimeParsingError : Error {
    var proposedString : String
}

func droppedFrameCount(for frameCount : Int) -> Int {
    let fps = 30
    let oneMinute = fps * 60
    let tenMinutes = oneMinute * 10
    
    let minutes = frameCount / oneMinute
    let tens = frameCount / tenMinutes
    return ( minutes - tens ) * 2
}

enum TimeRepresentation : CaseIterable {
    
    case timecode
    case timecodeDF
    case footage
    case realtime
    case samples
    
    private var regularExpression : NSRegularExpression {
        switch self {
        case .timecode:
            return try! NSRegularExpression(pattern: "(\\d+):(\\d\\d):(\\d\\d):(\\d\\d)(\\.\\d+)?" )
        case .timecodeDF:
            return try! NSRegularExpression(pattern: "(\\d+):(\\d\\d):(\\d\\d);(\\d\\d)(\\.\\d+)?" )
        case .footage:
            return try! NSRegularExpression(pattern: "(\\d+)\\+(\\d+)(\\.\\d+)?")
        case .realtime:
            return try! NSRegularExpression(pattern: "(\\d+):(\\d+)(\\.\\d)")
        case .samples:
            return try! NSRegularExpression(pattern: "^(\\d+)$")
        }
    }
    
    func detect(in string : String) -> Bool {
        if self.regularExpression.hasFirstMatch(in: string) != nil {
            return true
        } else {
            return false
        }
    }
    
    static func representationsMatching(string : String) -> [TimeRepresentation] {
        return TimeRepresentation.allCases.filter { $0.detect(in: string) }
    }
    
    static func terms(in string : String) throws -> (TimeRepresentation, [String?]) {
        guard let rep = TimeRepresentation
            .representationsMatching(string: string)
            .first,
            let terms = rep.regularExpression.hasFirstMatch(in:string)?.dropFirst() else {
                throw ProToolsTimeParsingError(proposedString: string)
        }
        
        return (rep , Array(terms) )
    }
}

extension SessionEntity {
    
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
    
//    var isDropFrame() : Bool {
//        switch self.timecodeFormat {
//        case "29.97 Drop Frame":    fallthrough
//        case "30 Drop Frame":       return true
//        default:                    return false
//        }
//    }
    
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

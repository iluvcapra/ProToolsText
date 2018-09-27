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
    
    static func terms(in string : String) -> (TimeRepresentation, [String?])? {
        if let rep = TimeRepresentation
            .representationsMatching(string: string)
            .first,
            let terms = rep.regularExpression.hasFirstMatch(in:string)?.dropFirst() {
            
            return (rep , Array(terms) )
        } else {
            return nil
        }
        
        
    }
}

extension PTEntityParser.SessionEntity {
    
    func frameDuration() throws -> CMTime {
        switch self.timecodeFormat {
        case "23.976 Frame":        return CMTime(value: 1001, timescale: 24000)
        case "24 Frame":            return CMTime(value: 1, timescale: 24)
        case "29.97 Frame":         fallthrough
        case "29.97 Drop Frame":    return CMTime(value: 1001, timescale: 30000)
        case "30 Frame":            fallthrough
        case "30 Drop Frame":       return CMTime(value: 1, timescale: 30)
        default:
            throw ProToolsTimeParsingError(proposedString: self.timecodeFormat)
        }
    }
    
    func isDropFrame(from session : PTEntityParser.SessionEntity) -> Bool {
        switch self.timecodeFormat {
        case "29.97 Drop Frame":    fallthrough
        case "30 Drop Frame":       return true
        default:                    return false
        }
    }
    
    func decodeTime(from string : String) -> CMTime {
        return CMTime.zero
    }
    
}

extension CMTime {
    
    static func from(ProToolsTimecode string : String,
                     from session : PTEntityParser.SessionEntity) throws -> CMTime {
        
        return CMTime.zero
    }
    
}


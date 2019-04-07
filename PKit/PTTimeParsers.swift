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

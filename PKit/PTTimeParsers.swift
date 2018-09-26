//
//  PTTimeParsers.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 9/25/18.
//

import Foundation
import CoreMedia

struct ProToolsTimeParsingError : Error {
    
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
            throw ProToolsTimeParsingError()
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


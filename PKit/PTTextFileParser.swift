//
//  PTTextFileParser.swift
//  PKit
//
//  Created by Jamie Hardt on 12/20/17.
//

import Cocoa

public protocol PTTextFileParserDelegate {
    
    func parserWillBegin(_ parser : PTTextFileParser)
    func parserDidFinish(_ parser : PTTextFileParser)
    
    func parser(_ parser : PTTextFileParser,
                         didReadSessionHeaderWithTitle: String,
                         sampleRate : Double,
                         bitDepth : String,
                         startTime : String,
                         timecodeFormat : String,
                         trackCount : Int,
                         clipsCount : Int,
                         filesCount : Int)
    
    func parser(_ parser : PTTextFileParser,
                willReadEventsForTrack: String,
                comments: String?,
                userDelay: String,
                stateFlags: [String],
                plugins: [String])
    
    func parser(_ parser: PTTextFileParser,
                didReadEventNamed: String,
                channel: Int,
                eventNumber: Int,
                start : String,
                end : String,
                duration : String,
                timestamp : String?,
                state: String)
    
    func parser(_ parser : PTTextFileParser,
                didReadMemoryLocation: Int,
                atLocation: String,
                timeReference: Int,
                units: String,
                name: String,
                comments: String?)
    
    func parserDidFinishReadingTrack(_ parser :PTTextFileParser)
    
}


public class PTTextFileParser: NSObject {
    
    private enum Token {
        case Begin
        case TripleLineBreak
        case LineBreak
        case ColumnBreak
        
        case Field
        case End
    }
    
    private struct ParseTokenError : Error {
        var expected : Token
        var found : Token
        var column : Int
        var line : Int
    }
    
    private struct ParseNumberError : Error {
        var column : Int
        var line : Int
    }
    
    
    public var delegate : PTTextFileParserDelegate?
    
    private var scanner : Scanner? = nil
    private var lineNumber = 1
    private var thisLineStarts = 0
    private var thisToken : Token = .Begin
    private var fieldValue : String = ""
    
    private func nextToken() {
        guard let s = scanner else {
            precondition(false)
        }
        
        var buffer : NSString? = nil
        let charSet = CharacterSet(charactersIn: "\t\n")
        
        if !s.isAtEnd {
            if s.scanString("\n\n\n", into: nil) {
                thisToken = .TripleLineBreak
                lineNumber += 3
                thisLineStarts = s.scanLocation
            } else if s.scanString("\n", into: nil) {
                thisToken =  .LineBreak
                lineNumber += 1
                thisLineStarts = s.scanLocation
            } else if s.scanString("\t", into: nil) {
                thisToken =  .ColumnBreak
            } else {
                s.scanUpToCharacters(from: charSet, into: &buffer)
                let readText = buffer! as String
                
                switch readText {
                default:
                    thisToken = .Field
                    fieldValue = readText
                }
                

            }
        } else {
            thisToken =  .End
        }
    }
    
    
    // MARK: -
    
    private func skipUntilAccept(token : Token) {
        while true {
            if accept(token: token) { break }
            nextToken()
            if accept(token: .End) { break }
        }
    }
    
    private func accept(token t: Token) -> Bool {
        switch thisToken {
        case t:
            nextToken()
            return true
        default:
            return false
        }
    }
    
    private func accept(string s : String) -> Bool {
        if (thisToken == .Field && fieldValue == s) {
            nextToken()
            return true
        } else {
            return false
        }
    }
    
    private func acceptString() -> String? {
        return accept(token: .Field) ? fieldValue : nil
    }
    
    private func acceptInteger() -> Int? {
        if (thisToken == .Field) {
            if let ival = Int(fieldValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
                nextToken()
                return ival
            }
        }
        return nil
    }
    
    private func expect(token t: Token) throws {
        if accept(token: t) {
            return
        } else {
            throw ParseTokenError(expected: t, found: thisToken, column: scanner!.scanLocation - thisLineStarts, line: lineNumber)
        }
    }
    
    private func expect(string s : String) throws {
        try expect(token: .Field)
        if fieldValue == s {
            return
        } else {
            throw ParseTokenError(expected: .Field, found: thisToken,
                                  column: scanner!.scanLocation - thisLineStarts,
                                  line: lineNumber)
        }
    }
    
    private func expectString() throws -> String {
        try expect(token: .Field)
        return fieldValue
    }
    
    private func expectInteger() throws -> Int {
        try expect(token: .Field)
        let stripped = fieldValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if let i = Int(stripped) {
            return i
        } else {
            throw ParseNumberError(column: scanner!.scanLocation - thisLineStarts,
                                   line: lineNumber)
        }
    }
    
    private func expectDouble() throws -> Double {
        try expect(token: .Field)
        if let i = Double(fieldValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return i
        } else {
            throw ParseNumberError(column: scanner!.scanLocation - thisLineStarts,
                                   line: lineNumber)
        }
    }
    
    // MARK: -
    
    private func header() throws {
            try expect(string: "SESSION NAME:")
            try expect(token: .ColumnBreak)
            let title = try expectString()
            try expect(token: .LineBreak)
            
            try expect(string: "SAMPLE RATE:")
            try expect(token: .ColumnBreak)
            let sampleRate = try expectDouble()
            try expect(token: .LineBreak)
            
            try expect(string: "BIT DEPTH:")
            try expect(token: .ColumnBreak)
            let bitDepth = try expectString()
            try expect(token: .LineBreak)
            
            try expect(string: "SESSION START TIMECODE:")
            try expect(token: .ColumnBreak)
            let sessionStart = try expectString()
            try expect(token: .LineBreak)
            
            try expect(string: "TIMECODE FORMAT:")
            try expect(token: .ColumnBreak)
            let tcFormat = try expectString()
            try expect(token: .LineBreak)
            
            try expect(string: "# OF AUDIO TRACKS:")
            try expect(token: .ColumnBreak)
            let trackCount = try expectInteger()
            try expect(token: .LineBreak)
            
            try expect(string: "# OF AUDIO CLIPS:")
            try expect(token: .ColumnBreak)
            let clipsCount = try expectInteger()
            try expect(token: .LineBreak)
            
            try expect(string: "# OF AUDIO FILES:")
            try expect(token: .ColumnBreak)
            let filesCount = try expectInteger()
            try expect(token: .TripleLineBreak)
            
            delegate?.parser(self, didReadSessionHeaderWithTitle: title,
                             sampleRate: sampleRate,
                             bitDepth: bitDepth, startTime: sessionStart,
                             timecodeFormat: tcFormat,
                             trackCount: trackCount,
                             clipsCount: clipsCount,
                             filesCount: filesCount)
    }
    
    private func files() throws {
        try expect(token: .LineBreak)
        try expect(token: .Field) // "Filename"
        try expect(token: .ColumnBreak)
        try expect(string: "Location")
        while !accept(token: .TripleLineBreak) {
            try expect(token: .LineBreak)
            try expect(token: .Field)
            try expect(token: .ColumnBreak)
            try expect(token: .Field)
        }
    }
    
    private func onlineClips() {
        // to be implemented
        skipUntilAccept(token: .TripleLineBreak)
    }
    
    private func plugins() {
        // to be implemented
        skipUntilAccept(token: .TripleLineBreak)
    }
    
    private func trackHeader() throws {
        try expect(token: .ColumnBreak)
        let trackName = try expectString()
        try expect(token: .LineBreak)
        try expect(string: "COMMENTS:")
        try expect(token: .ColumnBreak)
        let comments = acceptString()
        try expect(token: .LineBreak)
        try expect(string: "USER DELAY:")
        try expect(token: .ColumnBreak)
        let userDelay = try expectString()
        try expect(token: .LineBreak)
        try expect(string: "STATE: ")
        var states = [String]()
        while accept(token: .ColumnBreak) {
            states.append(try expectString())
        }
        try expect(token: .LineBreak)
        try expect(string: "PLUG-INS: ")
        var plugins = [String]()
        while accept(token: .ColumnBreak) {
            plugins.append(try expectString())
        }
        try expect(token: .LineBreak)
        
        delegate?.parser(self, willReadEventsForTrack: trackName,
                         comments: comments,
                         userDelay: userDelay,
                         stateFlags: states,
                         plugins: plugins)
        
        try expect(string: "CHANNEL ")
        try expect(token: .ColumnBreak)
        try expect(string: "EVENT   ")
        try expect(token: .ColumnBreak)
        try expect(string: "CLIP NAME                     ")
        try expect(token: .ColumnBreak)
        try expect(string: "START TIME    ")
        try expect(token: .ColumnBreak)
        try expect(string: "END TIME      ")
        try expect(token: .ColumnBreak)
        try expect(string: "DURATION      ")
        try expect(token: .ColumnBreak)
        if accept(string: "TIMESTAMP         ") {
            try expect(token: .ColumnBreak)
        }
        try expect(string: "STATE")
    }
    
    private func trackEventList() throws {
        repeat {
            if accept(token: .TripleLineBreak) || accept(token: .LineBreak) {
                continue
            } else if let channel = acceptInteger() {
                try expect(token: .ColumnBreak)
                let event = try expectInteger()
                try expect(token: .ColumnBreak)
                let clipName = try expectString()
                try expect(token: .ColumnBreak)
                let startTime = try expectString()
                try expect(token: .ColumnBreak)
                let endTime = try expectString()
                try expect(token: .ColumnBreak)
                let duration = try expectString()
                try expect(token: .ColumnBreak)
                let fieldY = try expectString()
                if accept(token: .ColumnBreak) {
                    let fieldZ = try expectString()
                    
                    delegate?.parser(self, didReadEventNamed: clipName.trimmingCharacters(in: .whitespacesAndNewlines),
                                     channel: channel,
                                     eventNumber: event,
                                     start: startTime.trimmingCharacters(in: .whitespacesAndNewlines),
                                     end: endTime.trimmingCharacters(in: .whitespacesAndNewlines),
                                     duration: duration.trimmingCharacters(in: .whitespacesAndNewlines),
                                     timestamp: fieldY.trimmingCharacters(in: .whitespacesAndNewlines),
                                     state: fieldZ.trimmingCharacters(in: .whitespacesAndNewlines))
                    
                } else {
                    delegate?.parser(self, didReadEventNamed: clipName.trimmingCharacters(in: .whitespacesAndNewlines),
                                     channel: channel,
                                     eventNumber: event,
                                     start: startTime.trimmingCharacters(in: .whitespacesAndNewlines),
                                     end: endTime.trimmingCharacters(in: .whitespacesAndNewlines),
                                     duration: duration.trimmingCharacters(in: .whitespacesAndNewlines),
                                     timestamp: nil,
                                     state: fieldY.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                

            } else {
                break
            }
        } while true
    }
    
    private func track() throws {
        try trackHeader()
        try trackEventList()
        delegate?.parserDidFinishReadingTrack(self)
    }

    private func markers() throws {
        try expect(token: .LineBreak)
        try expect(string: "#   ")
        try expect(token: .ColumnBreak)
        try expect(string: "LOCATION     ")
        try expect(token: .ColumnBreak)
        try expect(string: "TIME REFERENCE    ")
        try expect(token: .ColumnBreak)
        try expect(string: "UNITS    ")
        try expect(token: .ColumnBreak)
        try expect(string: "NAME                             ")
        try expect(token: .ColumnBreak)
        try expect(string: "COMMENTS")
        try expect(token: .LineBreak)
        
        repeat {
            guard let number = acceptInteger() else {
                break
            }
            try expect(token: .ColumnBreak)
            let location = try expectString()
            try expect(token: .ColumnBreak)
            let timeRef = try expectInteger()
            try expect(token: .ColumnBreak)
            let units = try expectString()
            try expect(token: .ColumnBreak)
            let name = try expectString()
            try expect(token: .ColumnBreak)
            let comments = acceptString()
            try expect(token: .LineBreak)
            delegate?.parser(self, didReadMemoryLocation: number,
                             atLocation: location,
                             timeReference: timeRef,
                             units: units,
                             name: name,
                             comments: comments)
        } while true
    }
    
    private func parseTextFile() throws {
        try header()
        if accept(string: "F I L E S  I N  S E S S I O N") {
            try files()
        }
        if accept(string: "O N L I N E  C L I P S  I N  S E S S I O N") {
            onlineClips()
        }
        if accept(string: "P L U G - I N S  L I S T I N G") {
            plugins()
        }
        if accept(string: "T R A C K  L I S T I N G") {
            try expect(token: .LineBreak)
            while accept(string: "TRACK NAME:") {
                try track()
            }
        }
        if accept(string: "M A R K E R S  L I S T I N G") { try markers() }
    }
    
    // MARK: -
    
    public func parse(data : Data, encoding : UInt) throws {
        let dataString = NSString(data: data, encoding: encoding)! as String
        scanner = Scanner(string: dataString)
        scanner?.charactersToBeSkipped = nil
        try expect(token: .Begin)
        delegate?.parserWillBegin(self)
        try parseTextFile()
        delegate?.parserDidFinish(self)
    }
    
}

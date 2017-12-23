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
    
    func parser(_ parser :PTTextFileParser,
                didFinishReadingEventsForTrack : String)
    
}


public class PTTextFileParser: NSObject {
    
    private enum Token {
        case Begin
        case TripleLineBreak
        case LineBreak
        case ColumnBreak
        
        case FilesHeader
        case OnlineClipsHeader
        case PlugInsHeader
        case TrackListingHeader
        case TrackName
        case TimestampHeader
        case MarkersHeader
        
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
    
    
    var delegate : PTTextFileParserDelegate?
    
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
                case "F I L E S  I N  S E S S I O N":
                    thisToken = .FilesHeader
                case "O N L I N E  C L I P S  I N  S E S S I O N":
                    thisToken = .OnlineClipsHeader
                case "P L U G - I N S  L I S T I N G":
                    thisToken = .PlugInsHeader
                case "T R A C K  L I S T I N G":
                    thisToken = .TrackListingHeader
                case "M A R K E R S  L I S T I N G":
                    thisToken = .MarkersHeader
                case "TRACK NAME:":
                    thisToken = .TrackName
                    
                case "TIMESTAMP         ":
                    thisToken = .TimestampHeader
                    
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
    private func accept(token t: Token) -> Bool {
        switch thisToken {
        case t:
            nextToken()
            return true
        default:
            return false
        }
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
        if let i = Int(fieldValue) {
            return i
        } else {
            throw ParseNumberError(column: scanner!.scanLocation - thisLineStarts,
                                   line: lineNumber)
        }
    }
    
    private func expectDouble() throws -> Double {
        try expect(token: .Field)
        if let i = Double(fieldValue) {
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
        while true {
            if accept(token: .TripleLineBreak) || accept(token: .End) {
                break
            } else { nextToken() }
        }
    }
    
    private func plugins() {
        // to be implemented
        while true {
            if accept(token: .TripleLineBreak)  || accept(token: .End) {
                break
            } else { nextToken() }
        }
    }
    
    private func track() throws {
        try expect(token: .ColumnBreak)
        try expect(token: .Field) // track name
        let trackName = fieldValue
        try expect(token: .LineBreak)
        try expect(string: "COMMENTS:")
        try expect(token: .ColumnBreak)
        var comments : String? = nil
        if accept(token: .Field) {
            comments = fieldValue
        }
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
        let timestampsColumn =  accept(token: .TimestampHeader)
        if timestampsColumn {
            try expect(token: .ColumnBreak)
        }
        try expect(string: "STATE")
        
        while !accept(token: .TripleLineBreak) {
            try expect(token: .LineBreak)
            try expect(token: .Field) // channel
            try expect(token: .ColumnBreak)
            try expect(token: .Field) // event
            try expect(token: .ColumnBreak)
            try expect(token: .Field) // clip name
            try expect(token: .ColumnBreak)
            try expect(token: .Field) // start time
            try expect(token: .ColumnBreak)
            try expect(token: .Field) // end time
            try expect(token: .ColumnBreak)
            try expect(token: .Field) // duration
            try expect(token: .ColumnBreak)
            if timestampsColumn {
                try expect(token: .Field) // timestamp
                try expect(token: .ColumnBreak)
            }
            try expect(token: .Field) // state
        }
        delegate?.parser(self, didFinishReadingEventsForTrack: trackName)
    }

    private func markers() {
        
    }
    
    private func parseTextFile() throws {
        try header()
        if accept(token: .FilesHeader) {
            try files()
        }
        if accept(token: .OnlineClipsHeader) {
            onlineClips()
        }
        if accept(token: .PlugInsHeader) {
            plugins()
        }
        if accept(token: .TrackListingHeader) {
            try expect(token: .LineBreak)
            while accept(token: .TrackName) {
                try track()
            }
        }
        if accept(token: .MarkersHeader) { markers() }
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

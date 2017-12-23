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
    private func accept(_ t: Token) -> Bool {
        switch thisToken {
        case t:
            nextToken()
            return true
        default:
            return false
        }
    }
    
    private func expect(_ t: Token) throws {
        if accept(t) {
            return
        } else {
            throw ParseTokenError(expected: t, found: thisToken, column: scanner!.scanLocation - thisLineStarts, line: lineNumber)
        }
    }
    
    private func expectField(_ s : String) throws {
        try expect(.Field)
        if fieldValue == s {
            return
        } else {
            throw ParseTokenError(expected: .Field, found: thisToken,
                                  column: scanner!.scanLocation - thisLineStarts,
                                  line: lineNumber)
        }
    }
    
    private func expectString() throws -> String {
        try expect(.Field)
        return fieldValue
    }
    
    private func expectInteger() throws -> Int {
        try expect(.Field)
        if let i = Int(fieldValue) {
            return i
        } else {
            throw ParseNumberError(column: scanner!.scanLocation - thisLineStarts,
                                   line: lineNumber)
        }
    }
    
    private func expectDouble() throws -> Double {
        try expect(.Field)
        if let i = Double(fieldValue) {
            return i
        } else {
            throw ParseNumberError(column: scanner!.scanLocation - thisLineStarts,
                                   line: lineNumber)
        }
    }
    
    // MARK: -
    
    private func header() throws {
            try expectField("SESSION NAME:")
            try expect(.ColumnBreak)
            let title = try expectString()
            try expect(.LineBreak)
            
            try expectField("SAMPLE RATE:")
            try expect(.ColumnBreak)
            let sampleRate = try expectDouble()
            try expect(.LineBreak)
            
            try expectField("BIT DEPTH:")
            try expect(.ColumnBreak)
            let bitDepth = try expectString()
            try expect(.LineBreak)
            
            try expectField("SESSION START TIMECODE:")
            try expect(.ColumnBreak)
            let sessionStart = try expectString()
            try expect(.LineBreak)
            
            try expectField("TIMECODE FORMAT:")
            try expect(.ColumnBreak)
            let tcFormat = try expectString()
            try expect(.LineBreak)
            
            try expectField("# OF AUDIO TRACKS:")
            try expect(.ColumnBreak)
            let trackCount = try expectInteger()
            try expect(.LineBreak)
            
            try expectField("# OF AUDIO CLIPS:")
            try expect(.ColumnBreak)
            let clipsCount = try expectInteger()
            try expect(.LineBreak)
            
            try expectField("# OF AUDIO FILES:")
            try expect(.ColumnBreak)
            let filesCount = try expectInteger()
            try expect(.TripleLineBreak)
            
            delegate?.parser(self, didReadSessionHeaderWithTitle: title,
                             sampleRate: sampleRate,
                             bitDepth: bitDepth, startTime: sessionStart,
                             timecodeFormat: tcFormat,
                             trackCount: trackCount,
                             clipsCount: clipsCount,
                             filesCount: filesCount)
    }
    
    private func files() throws {
        try expect(.LineBreak)
        try expect(.Field) // "Filename"
        try expect(.ColumnBreak)
        try expectField("Location")
        while !accept(.TripleLineBreak) {
            try expect(.LineBreak)
            try expect(.Field)
            try expect(.ColumnBreak)
            try expect(.Field)
        }
    }
    
    private func onlineClips() {
        // to be implemented
        while true {
            if accept(.TripleLineBreak) || accept(.End) {
                break
            } else { nextToken() }
        }
    }
    
    private func plugins() {
        // to be implemented
        while true {
            if accept(.TripleLineBreak)  || accept(.End) {
                break
            } else { nextToken() }
        }
    }
    
    private func track() throws {
        try expect(.ColumnBreak)
        try expect(.Field) // track name
        let trackName = fieldValue
        try expect(.LineBreak)
        try expectField("COMMENTS:")
        try expect(.ColumnBreak)
        var comments : String? = nil
        if accept(.Field) {
            comments = fieldValue
        }
        try expect(.LineBreak)
        try expectField("USER DELAY:")
        try expect(.ColumnBreak)
        try expect(.Field)
        let userDelay = fieldValue
        try expect(.LineBreak)
        try expectField("STATE: ")
        var states = [String]()
        while accept(.ColumnBreak) {
            try expect(.Field)
            states.append(fieldValue)
        }
        try expect(.LineBreak)
        try expectField("PLUG-INS: ")
        var plugins = [String]()
        while accept(.ColumnBreak) {
            try expect(.Field)
            plugins.append(fieldValue)
        }
        try expect(.LineBreak)
        
        delegate?.parser(self, willReadEventsForTrack: trackName,
                         comments: comments,
                         userDelay: userDelay,
                         stateFlags: states,
                         plugins: plugins)
        
        try expectField("CHANNEL ")
        try expect(.ColumnBreak)
        try expectField("EVENT   ")
        try expect(.ColumnBreak)
        try expectField("CLIP NAME                     ")
        try expect(.ColumnBreak)
        try expectField("START TIME    ")
        try expect(.ColumnBreak)
        try expectField("END TIME      ")
        try expect(.ColumnBreak)
        try expectField("DURATION      ")
        try expect(.ColumnBreak)
        let timestampsColumn =  accept(.TimestampHeader)
        if timestampsColumn {
            try expect(.ColumnBreak)
        }
        try expectField("STATE")
        
        while !accept(.TripleLineBreak) {
            try expect(.LineBreak)
            try expect(.Field) // channel
            try expect(.ColumnBreak)
            try expect(.Field) // event
            try expect(.ColumnBreak)
            try expect(.Field) // clip name
            try expect(.ColumnBreak)
            try expect(.Field) // start time
            try expect(.ColumnBreak)
            try expect(.Field) // end time
            try expect(.ColumnBreak)
            try expect(.Field) // duration
            try expect(.ColumnBreak)
            if timestampsColumn {
                try expect(.Field) // timestamp
                try expect(.ColumnBreak)
            }
            try expect(.Field) // state
        }
        delegate?.parser(self, didFinishReadingEventsForTrack: trackName)
    }

    private func markers() {
        
    }
    
    private func parseTextFile() throws {
        try header()
        if accept(.FilesHeader) {
            try files()
        }
        if accept(.OnlineClipsHeader) {
            onlineClips()
        }
        if accept(.PlugInsHeader) {
            plugins()
        }
        if accept(.TrackListingHeader) {
            try expect(.LineBreak)
            while accept(.TrackName) {
                try track()
            }
        }
        if accept(.MarkersHeader) { markers() }
    }
    
    // MARK: -
    
    public func parse(data : Data, encoding : UInt) throws {
        let dataString = NSString(data: data, encoding: encoding)! as String
        scanner = Scanner(string: dataString)
        scanner?.charactersToBeSkipped = nil
        try expect(.Begin)
        delegate?.parserWillBegin(self)
        try parseTextFile()
        delegate?.parserDidFinish(self)
    }
    
}

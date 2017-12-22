//
//  PTTextFileParser.swift
//  PKit
//
//  Created by Jamie Hardt on 12/20/17.
//

import Cocoa

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
    
    private struct ParseError : Error {
        var expected : Token
        var found : Token
        var column : Int
        var line : Int
    }
    
    private var scanner : Scanner? = nil
    var lineNumber = 1
    var thisLineStarts = 0
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
            throw ParseError(expected: t, found: thisToken, column: scanner!.scanLocation - thisLineStarts, line: lineNumber)
        }
    }
    
    private func expectField(_ s : String) throws {
        try expect(.Field)
        if fieldValue == s {
            return
        } else {
            throw ParseError(expected: .Field, found: thisToken, column: scanner!.scanLocation - thisLineStarts, line: lineNumber)
        }
    }
    
    // MARK: -
    
    private func header() throws {
        while true {
            try expect(.Field)
            try expect(.ColumnBreak)
            try expect(.Field)
            if accept(.TripleLineBreak) {
                break
            } else {
                try expect(.LineBreak)
            }
        }
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
        try expect(.LineBreak)
        try expectField("COMMENTS:")
        try expect(.ColumnBreak)
        _ = accept(.Field) // If the comments are empty there are no characters here, it goes straight to the linebreak
        try expect(.LineBreak)
        try expectField("USER DELAY:")
        try expect(.ColumnBreak)
        try expect(.Field)
        try expect(.LineBreak)
        try expectField("STATE: ")
        while accept(.ColumnBreak) {
            try expect(.Field)
        }
        try expect(.LineBreak)
        try expectField("PLUG-INS: ")
        while accept(.ColumnBreak) {
            try expect(.Field)
        }
        try expect(.LineBreak)
        
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
        try parseTextFile()
    }
    
}

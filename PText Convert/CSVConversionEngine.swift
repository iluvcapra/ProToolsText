//
//  CSVConversionEngine.swift
//  ADR Spotting
//
//  Created by Jamie Hardt on 12/23/17.
//

import Cocoa
import PKit

class TagParser {
    enum Token {
        case Begin
        case Whitespace
        case Dollar
        case LeftBrace
        case RightBrace
        case LeftSquareBracket
        case RightSquareBracket
        case Equals
        case Word
        case End
    }
    
    struct TagParserError : Error {
        var at : Int
    }
    
    var scanner :Scanner
    var thisToken : Token = .Begin
    var thisWord : String?
    
    var name = ""
    var dict = [String:String]()
    
    func nextToken() {
        let exclusion = CharacterSet(charactersIn: "{}[]$=").union(CharacterSet.whitespaces)
        var buffer : NSString? = nil
        if scanner.scanCharacters(from: .whitespaces, into: nil) {
            thisToken = .Whitespace
            
        } else if scanner.scanString("$", into: nil) {
            thisToken = .Dollar
        } else if scanner.scanString("{", into: nil) {
            thisToken = .LeftBrace
        } else if scanner.scanString("}", into: nil) {
            thisToken = .RightBrace
        } else if scanner.scanString("[", into: nil) {
            thisToken = .LeftSquareBracket
        } else if scanner.scanString("]", into: nil) {
            thisToken = .RightSquareBracket
        } else if scanner.scanString("=", into: nil) {
            thisToken = .Equals
        } else if scanner.scanUpToCharacters(from: exclusion, into: &buffer) {
            thisToken = .Word
            thisWord = buffer! as String
        } else if scanner.isAtEnd {
            thisToken = .End
        }
    }
    
    func accept(token : Token) -> Bool {
        if token == thisToken {
            nextToken()
            return true
        } else {
            return false
        }
    }
    
    func expect(token : Token) throws {
        if !accept(token: token) {
            throw TagParserError(at: scanner.scanLocation)
        }
    }
    
    func nameDecl() {
        while true {
            if accept(token: .Word) {
                name += thisWord ?? ""
            } else if accept(token: .Whitespace) {
                name += " "
            } else {
                break
            }
        }
    }
    
    func dollarDecl() throws {
        let key : String
        let val : String
        try expect(token: .Word)
        key = thisWord!
        try expect(token: .Equals)
        try expect(token: .Word)
        val = thisWord!
        dict[key] = val
    }
    
    func braceDecl() throws {
        let key : String
        var val : String
        try expect(token: .Word)
        key = thisWord!
        try expect(token: .Equals)
        val = ""
        while true {
            if accept(token: .Word) {
                val.append(thisWord!)
            } else if accept(token: .Whitespace) {
                val.append(" ")
            } else {
                break
            }
        }
        try expect(token: .RightBrace)
        dict[key] = val
    }
    
    func bracketDecl() throws {
        let key : String
        try expect(token: .Word)
        key = thisWord!
        try expect(token: .RightSquareBracket)
        dict[key] = key
    }
    
    func fields() {
        while !scanner.isAtEnd {
            if accept(token: .Dollar) {
                try? dollarDecl()
            } else if accept(token: .LeftBrace) {
                try? braceDecl()
            } else if accept(token: .LeftSquareBracket) {
                try? bracketDecl()
            } else {
                nextToken()
            }
        }
    }
    
    func taggedString() {
        nameDecl()
        fields()
    }
    
    func parse() -> (text: String, fields: [String:String]) {
        name = ""
        try! expect(token: .Begin)
        taggedString()
        let txt = name.trimmingCharacters(in: .whitespaces)
        return (text : txt, fields: dict)
    }
    
    init(string s: String) {
        scanner = Scanner(string: s)
        scanner.charactersToBeSkipped = nil
    }
    
}

extension Dictionary {
    func mergeKeepCurrent(_ other : Dictionary<Key,Value>) -> Dictionary<Key, Value> {
        return self.merging(other, uniquingKeysWith: { (current, _) -> Value in current} )
    }
}

/*
 The SessionEntityRectifier takes parsed PTEntities and turns the lot into
 a list of dictionaries.
    - One dictionary is created for each Clip
    -
 */

protocol SessionEntityRectifierDelegate {
    func rectifier(_ r: SessionEntityRectifier, didReadRecord : [String:String])
}

class SessionEntityRectifier {
    
    private let session : PTEntityParser.SessionEntity
    private let markers : [PTEntityParser.MarkerEntity]
    private let tracks : [PTEntityParser.TrackEntity]
    
    var delegate : SessionEntityRectifierDelegate?
    
    private func fields(for track : PTEntityParser.TrackEntity) -> [String:String] {
        let trackNameParse = TagParser(string: track.rawTitle).parse()
        let trackCommentParse = TagParser(string : track.rawComment).parse()
        let trackDict : [String:String] = {
            var dict = trackNameParse.fields
            dict = dict.mergeKeepCurrent(trackCommentParse.fields)
            dict["TrackName"] = trackNameParse.text
            dict["RawTrackName"] = track.rawTitle
            dict["TrackComment"] = trackCommentParse.text
            dict["RawTrackComment"] = track.rawComment
            return dict
        }()
        return trackDict
    }
    
    private func fields(for clip: PTEntityParser.ClipEntity) -> [String:String] {
        let clipNameParse = TagParser(string: clip.rawName).parse()
        let clipDict : [String:String] = {
            var dict = clipNameParse.fields
            dict["EventNumber"] = String(clip.eventNumber)
            dict["ClipName"] = clipNameParse.text
            dict["RawClipName"] = clip.rawName
            dict["Start"] = clip.rawStart
            dict["Finish"] = clip.rawFinish
            dict["Duration"] = clip.rawDuration
            dict["Muted"] = clip.muted ? "Muted" : ""
            return dict
        }()
        return clipDict
    }
    
    private func interpret(track : PTEntityParser.TrackEntity) {
        let trackFields = fields(for: track)
        
        for clip in track.clips {
            let clipFields = fields(for: clip)
            let record = clipFields.mergeKeepCurrent(trackFields)
            delegate?.rectifier(self, didReadRecord: record)
        }
    }
    
    func interpetRecords() {
        for track in tracks {
            interpret(track:track)
        }
    }
    
    init(tracks: [PTEntityParser.TrackEntity],
        markers: [PTEntityParser.MarkerEntity],
        session: PTEntityParser.SessionEntity) {
        self.session = session
        self.markers = markers
        self.tracks = tracks
    }
}

class CSVConversionEngine: NSObject {
    
    var outputRecords : [[String:String]] = []
    
    func convert(fileURL : URL, encoding: String.Encoding, to : URL, baseName : String) throws {
        let textParser = PTTextFileParser()
        
        let entityParser = PTEntityParser()
        textParser.delegate = entityParser
        
        let fileData = try Data(contentsOf: fileURL)
        try textParser.parse(data: fileData, encoding: encoding.rawValue)
        
        
    }
}

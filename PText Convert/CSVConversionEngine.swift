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
        } else {
            return
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
    
    func parse() -> [String:String] {
        name = ""
        try! expect(token: .Begin)
        taggedString()
        dict["_name"] = name.trimmingCharacters(in: .whitespaces)
        return dict
    }
    
    init(string s: String) {
        scanner = Scanner(string: s)
        scanner.charactersToBeSkipped = nil
    }
    
}

class TagInterpreter {
    
    func interpretClips(inTracks: [PTEntityParser.TrackEntity],
                        applyMarkers: [PTEntityParser.MarkerEntity],
                        applySession: PTEntityParser.SessionEntity) {
       // let sessionFields = extractFields(from: applySession.rawTitle)
        
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

//
//  FieldParser.swift
//  ADR Spotting
//
//  Created by Jamie Hardt on 12/24/17.
//

import Foundation
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
    
    var scanner : JHScanner<String.UnicodeScalarView>
    var thisToken : Token = .Begin
    var thisWord : String?
    
    var name = ""
    var dict = [String:String]()
    
    func nextToken() {
        let exclusion = CharacterSet(charactersIn: "{}[]$=").union(CharacterSet.whitespaces)
        
        if scanner.accept(characterfromSet: CharacterSet.whitespaces)  {
            thisToken = .Whitespace
            
        } else if scanner.accept(string:"$") {
            thisToken = .Dollar
        } else if scanner.accept(string:"{") {
            thisToken = .LeftBrace
        } else if scanner.accept(string:"}") {
            thisToken = .RightBrace
        } else if scanner.accept(string:"[") {
            thisToken = .LeftSquareBracket
        } else if scanner.accept(string:"]") {
            thisToken = .RightSquareBracket
        } else if scanner.accept(string:"=") {
            thisToken = .Equals
        } else if scanner.atEnd {
            thisToken = .End
        } else {
            let buffer = scanner.readWhile(characters: exclusion.inverted)
            thisToken = .Word
            thisWord = buffer
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
            throw TagParserError(at: scanner.consumed)
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
        while !scanner.atEnd {
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
        scanner = JHScanner(string: s)
    }
    
}

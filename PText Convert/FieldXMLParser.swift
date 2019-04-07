//
//  FieldXMLParser.swift
//  PText Convert
//
//  Created by Jamie Hardt on 4/7/19.
//

import Foundation
import PKit

/**
 
 The XMLTagParser takes text strings and converts them into XML nodes.
 
 The input string is parsed as a series of words, which are converted either into text nodes
 or element nodes:
 
     Good morning, \em{everyone}! Welcome. \noise \qn{G1001} \tbw \char{\name{Bill} \actor{Brad Pitt} }
 
 Has the output
 
     Good morning <em>everyone</em>! Welcome. <noise/> <qn>G1001</qn> <tbw/>
     <char><name>Bill</name> <actor>Brad Pitt</actor></char>

 String can also begin with an initial "!", in which case they are not translated but are passed on to
 the conversion engine as commands.
 
 */
class XMLTagParser {
    
    enum Token {
        case Backslash
        case Word(value : String)
        case WordSeparator
        case BeginElement
        case EndElement
        case Excl
        
        var charSet: CharacterSet {
            switch self {
            case .Backslash:        return CharacterSet(charactersIn: "\\")
            case .WordSeparator:    return CharacterSet(charactersIn: " ")
            case .BeginElement:     return CharacterSet(charactersIn: "{")
            case .EndElement:       return CharacterSet(charactersIn: "}")
            case .Excl:             return CharacterSet(charactersIn: "!")
            default:
                var wordSet = CharacterSet.alphanumerics
                wordSet.remove(charactersIn: "\\ {}!")
                return wordSet
            }
        }
    }
    
    struct XMLTagParserError : Error {
        var at : Int
    }

}

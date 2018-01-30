//
//  XMLStringDictionary.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 1/29/18.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    
    func toXMLElement(named n : String) -> XMLElement? {
        
        let retVal = XMLElement(name: n)
        
        func sanatizeElementName(_ key : String) -> String {
            // https://www.w3schools.com/xml/xml_elements.asp
            
            guard key.count > 0 else {
                return "_null"
            }
            
            let legalElementChar = CharacterSet.alphanumerics
                .union(CharacterSet(charactersIn: "-_."))
            let illegalElements = legalElementChar.inverted
            
            let legalComponents = key.components(separatedBy: illegalElements)
            
            let legalFirstCharacters = CharacterSet.letters.union(CharacterSet(charactersIn:"_"))
            
            let residual = legalComponents.joined(separator: "_")
            
            if !legalFirstCharacters.contains(residual.unicodeScalars.first!) || residual.prefix(3).compare("xml",
                                          options: String.CompareOptions.caseInsensitive,
                                          range: nil, locale: nil) == ComparisonResult.orderedSame {
                return "_" + residual
            } else {
               return residual
            }
        }
        
        for (key, value) in self {
            let saneKey = sanatizeElementName(key)
            let memberElement = XMLElement(name: saneKey,
                                           stringValue: value)
            retVal.addChild(memberElement)
        }
        
        return retVal
    }
    
}

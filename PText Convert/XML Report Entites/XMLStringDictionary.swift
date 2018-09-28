//
//  XMLStringDictionary.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 1/29/18.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    
    func toXMLElement(named n : String) -> XMLElement {
        
        let retVal = XMLElement(name: n)

        
        for (key, value) in self {
             if !value.isEmpty {
                let memberElement = XMLElement(name: "field")
                if key != value {
                    let keyElement = XMLElement(name: "key", stringValue: key)
                    let valueElement = XMLElement(name: "value", stringValue: value)
                    
                    memberElement.addChild(keyElement)
                    memberElement.addChild(valueElement)
                    
                } else {
                    let propertyElement = XMLElement(name: "property", stringValue: key)
                    memberElement.addChild(propertyElement)
                }
                retVal.addChild(memberElement)
            }
        }
        
        return retVal
    }
    
}

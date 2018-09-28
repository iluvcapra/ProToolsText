//
//  XMLStringDictionary.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 1/29/18.
//

import Foundation
import CoreMedia

protocol XMLRepresentable {
    
    func xmlEntity() -> XMLNode
    
}

extension String: XMLRepresentable {
    
    func xmlEntity() -> XMLNode {
        let node = XMLNode(kind: XMLNode.Kind.text)
        node.stringValue = self
        return node
    }
}

extension CMTime: XMLRepresentable {
    
    func xmlEntity() -> XMLNode {
        let retVal = XMLElement(name: "CMTime")
        switch self {
        case CMTime.positiveInfinity:
            retVal.addChild(XMLElement(name: "positive-infinity"))
        case CMTime.negativeInfinity:
            retVal.addChild(XMLElement(name: "negative-infinity"))
        case CMTime.indefinite:
            retVal.addChild(XMLElement(name: "indefinite"))
        case CMTime.invalid:
            retVal.addChild(XMLElement(name: "invalid"))
        default:
            retVal.addChild(XMLElement(name: "value", stringValue: String(self.value)))
            retVal.addChild(XMLElement(name: "timescale", stringValue: String(self.timescale)))
        }
        
        return retVal
    }
}

enum EventRecordValue {
    case string(String)
    case time(CMTime)
}

typealias EventRecord = [String:String]

extension Dictionary where Key == String, Value == String {
    
    func toXMLElement(named n : String) -> XMLElement {
        
        let retVal = XMLElement(name: n)

        for (key, value) in self {
            let memberElement : XMLElement = XMLElement(name: "field")
            if key == value {
                let propertyElement = XMLElement(name: "property", stringValue: key)
                memberElement.addChild(propertyElement)
                
            } else {
                let keyElement = XMLElement(name: "key", stringValue: key)
                let valueElement = XMLElement(name: "value")
                valueElement.addChild( value.xmlEntity() )
                memberElement.addChild(keyElement)
                memberElement.addChild(valueElement)
            }
            retVal.addChild(memberElement)
        }
        
        return retVal
    }
    
}

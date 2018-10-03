//
//  XMLConversionEngine.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 1/30/18.
//

import Cocoa
import PKit


class XMLConversionEngine: NSObject {

    enum Stylesheet {
        case none
        case structured
        case filemaker
    }
    
    var stylesheet : Stylesheet = .none
    
    private func rawDocument(with records : [EventRecord], from url : URL) -> XMLDocument {
        
        let root = XMLElement(name: "pttext")
        root.addChild(XMLNode.comment(withStringValue: "Be advised this XML format is under active development and the schema may change at any time") as! XMLNode)
        root.setAttributesAs(["testMode" : "true"])
        
        let docInfo = XMLElement(name: "document-information")
        
        docInfo.addChild(XMLElement(name: "producer-identifer", stringValue: Bundle.main.bundleIdentifier))
        docInfo.addChild(XMLElement(name: "producer-version", stringValue: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""))
        
        docInfo.addChild(XMLElement(name: "production-hostname", stringValue: Host.current().localizedName ))
        docInfo.addChild(XMLElement(name: "production-user", stringValue: NSFullUserName() ))
        
        docInfo.addChild(XMLElement(name: "input-document", stringValue: url.lastPathComponent))
        docInfo.addChild(XMLElement(name: "production-date", stringValue: ISO8601DateFormatter().string(from: Date() ) ))
        
        
        root.addChild(docInfo)
        
        let eventsEntity = XMLElement(name: "events")
        for record in records {
            let event = record.toXMLElement(named: "event")
            eventsEntity.addChild(event)
        }
        
        root.addChild(eventsEntity)
        return XMLDocument(rootElement: root)
    }
    
    func convert(fileURL : URL, to : URL) throws {
        let entityParser = try PTEntityParser(url: fileURL, encoding: String.Encoding.utf8.rawValue)
        let tabulator = SessionEntityTabulator(tracks: entityParser.tracks,
                                               markers: entityParser.markers,
                                               session: entityParser.session!)
        
        tabulator.interpetRecords()
        
        let records = tabulator.records
        
        let document = rawDocument(with : records , from : fileURL)
        
        let fmpXSLURL   = Bundle.main.url(forResource: "FMPXMLRESULT", withExtension: "xsl")!
        
        let structuredXSLURL = Bundle.main.url(forResource: "ADR_Structured", withExtension: "xsl")!
        
        let structuredXMLDocument = try document.objectByApplyingXSLT(at: structuredXSLURL, arguments: nil) as! XMLDocument
        
        
        let fmpDocument =       try structuredXMLDocument.objectByApplyingXSLT(at: fmpXSLURL,
                                                                           arguments: nil) as! XMLDocument

        
        
        let finalDocument : XMLDocument
        let data : Data
        let xmlOptions : XMLDocument.Options = [XMLNode.Options.nodeCompactEmptyElement, .nodePrettyPrint]
        switch stylesheet {
        case .none:
            finalDocument = document
            data = finalDocument.xmlData(options: xmlOptions )
        case .filemaker:
            finalDocument = fmpDocument
            data = finalDocument.xmlData(options: xmlOptions )
        case .structured:
            finalDocument = structuredXMLDocument
            data = finalDocument.xmlData(options: xmlOptions )
        }
        
        try data.write(to: to)
    }
}

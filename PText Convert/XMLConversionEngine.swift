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
        //case basic
        case adr
        case filemaker
    }
    
    var stylesheet : Stylesheet = .adr
    
    private func rawDocument(with records : [[String:String]], from url : URL) -> XMLDocument {
        
        let root = XMLElement(name: "pttext")
        root.addChild(XMLNode.comment(withStringValue: "Be advised this XML format is under active development and the schema may change at any time") as! XMLNode)
        root.setAttributesAs(["testMode" : "true"])
        
        let docInfo = XMLElement(name: "document_information")
        
        
        docInfo.addChild(XMLElement(name: "producer_identifer", stringValue: Bundle.main.bundleIdentifier))
        docInfo.addChild(XMLElement(name: "producer_version", stringValue: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""))
        docInfo.addChild(XMLElement(name: "input_document", stringValue: url.lastPathComponent))
        docInfo.addChild(XMLElement(name: "production_date", stringValue: ISO8601DateFormatter().string(from: Date() ) ))
        
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
        
        let adrXSLURL   = Bundle.main.url(forResource: "ADR", withExtension: "xsl")!
        let fmpXSLURL   = Bundle.main.url(forResource: "FMPXMLRESULT", withExtension: "xsl")!
        
        let adrxmlDocument =    try document.objectByApplyingXSLT(at: adrXSLURL, arguments: nil) as! XMLDocument
        let fmpDocument =       try adrxmlDocument.objectByApplyingXSLT(at: fmpXSLURL,
                                                                        arguments: ["filename": to.lastPathComponent]) as! XMLDocument
        
        let finalDocument : XMLDocument
        switch stylesheet {
        case .none:
            finalDocument = document
        case .adr:
            finalDocument = adrxmlDocument
        case .filemaker:
            finalDocument = fmpDocument
        }
        
        let data = finalDocument.xmlData(options: [XMLNode.Options.nodePrettyPrint] )
        
        try data.write(to: to)
    }
}

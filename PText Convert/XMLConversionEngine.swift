//
//  XMLConversionEngine.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 1/30/18.
//

import Cocoa
import PKit


class XMLConversionEngine: NSObject {

    func convert(fileURL : URL, to : URL) throws {
        let entityParser = try PTEntityParser(url: fileURL, encoding: String.Encoding.utf8.rawValue)
        let tabulator = SessionEntityTabulator(tracks: entityParser.tracks,
                                               markers: entityParser.markers,
                                               session: entityParser.session!)
        
        tabulator.interpetRecords()
        
        let records = tabulator.records
        
        let root = XMLElement(name: "pttext")
        root.addChild(XMLNode.comment(withStringValue: "Be advised this XML format is under active development and the schema may change at any time") as! XMLNode)
        root.setAttributesAs(["testMode" : "true"])
        root.addChild(XMLElement(name: "producer_identifer", stringValue: Bundle.main.bundleIdentifier))
        root.addChild(XMLElement(name: "producer_version", stringValue: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""))
        let eventsEntity = XMLElement(name: "events")
        for record in records {
            let event = record.toXMLElement(named: "event")
            eventsEntity.addChild(event)
        }
        
        root.addChild(eventsEntity)
        let document = XMLDocument(rootElement: root)
        
        let basicXSLURL = Bundle.main.url(forResource: "Basic", withExtension: "xsl")!
        
        let finalDocument = try document.objectByApplyingXSLT(at: basicXSLURL, arguments: nil) as! XMLDocument
        
        let data = finalDocument.xmlData(options: [XMLNode.Options.nodePrettyPrint, XMLNode.Options.nodeCompactEmptyElement] )
        
        try data.write(to: to)
    }
}

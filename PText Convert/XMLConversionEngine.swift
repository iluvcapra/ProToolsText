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
        case adrhtml
    }
    
    var stylesheet : Stylesheet = .adr
    
    private func rawDocument(with records : [EventRecord], from url : URL) -> XMLDocument {
        
        let root = XMLElement(name: "pttext")
        root.addChild(XMLNode.comment(withStringValue: "Be advised this XML format is under active development and the schema may change at any time") as! XMLNode)
        root.setAttributesAs(["testMode" : "true"])
        
        let docInfo = XMLElement(name: "document_information")
        
        docInfo.addChild(XMLElement(name: "producer_identifer", stringValue: Bundle.main.bundleIdentifier))
        docInfo.addChild(XMLElement(name: "producer_version", stringValue: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""))
        
        docInfo.addChild(XMLElement(name: "production_hostname", stringValue: Host.current().localizedName ))
        docInfo.addChild(XMLElement(name: "production_user", stringValue: NSFullUserName() ))
        
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
        let adrhtmlXSLURL   = Bundle.main.url(forResource: "ADR-html", withExtension: "xsl")!
        
        let adrxmlDocument =    try document.objectByApplyingXSLT(at: adrXSLURL, arguments: nil) as! XMLDocument
        let fmpDocument =       try adrxmlDocument.objectByApplyingXSLT(at: fmpXSLURL,
                                                                        arguments: nil) as! XMLDocument
        let adrHtmlDocument =   try adrxmlDocument.objectByApplyingXSLT(at: adrhtmlXSLURL,
                                                                        arguments: nil) as! Data
        
        
        let finalDocument : XMLDocument
        let data : Data
        switch stylesheet {
        case .none:
            finalDocument = document
            data = finalDocument.xmlData(options: [XMLNode.Options.nodePrettyPrint] )
        case .adr:
            finalDocument = adrxmlDocument
            data = finalDocument.xmlData(options: [XMLNode.Options.nodePrettyPrint] )
        case .filemaker:
            finalDocument = fmpDocument
            data = finalDocument.xmlData(options: [XMLNode.Options.nodePrettyPrint] )
        case .adrhtml:
            data = adrHtmlDocument
        }
        
        try data.write(to: to)
    }
}

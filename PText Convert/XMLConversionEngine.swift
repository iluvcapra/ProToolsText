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
        
        let eventsEntity = XMLElement(name: "events")
        for record in records {
            let event = record.toXMLElement(named: "event")
            eventsEntity.addChild(event)
        }
        
        root.addChild(eventsEntity)
        let document = XMLDocument(rootElement: root)
        let data = document.xmlData(options: XMLNode.Options.nodePrettyPrint)
        
        try data.write(to: to)
    }
}

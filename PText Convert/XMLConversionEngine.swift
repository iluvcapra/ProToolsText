//
//  XMLConversionEngine.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/31/17.
//

import Cocoa
import PKit

class XMLConversionEngine: NSObject {
    
    private func xmlElement(session : PTEntityParser.SessionEntity,
                            markers : [PTEntityParser.MarkerEntity],
                            tracks: [PTEntityParser.TrackEntity]) -> XMLElement {
        let sessionElement = XMLElement(name: "session")
        
        return sessionElement
    }
    
    
    func convert(fileURL : URL, encoding: String.Encoding, to : URL) throws {
        
    }
}

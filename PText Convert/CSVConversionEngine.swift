//
//  CSVConversionEngine.swift
//  ADR Spotting
//
//  Created by Jamie Hardt on 12/23/17.
//

import Cocoa
import PKit

extension Dictionary {
    func mergeKeepCurrent(_ other : Dictionary<Key,Value>) -> Dictionary<Key, Value> {
        return self.merging(other, uniquingKeysWith: { (current, _) -> Value in current} )
    }
}


class CSVConversionEngine: NSObject {
    
    var outputRecords : [[String:String]] = []
    
    func convert(fileURL : URL, encoding: String.Encoding, to : URL, baseName : String) throws {
        let textParser = PTTextFileParser()
        
        let entityParser = PTEntityParser()
        textParser.delegate = entityParser
        
        let fileData = try Data(contentsOf: fileURL)
        try textParser.parse(data: fileData, encoding: encoding.rawValue)
        
        
    }
}

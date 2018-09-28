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

class CSVWriter: NSObject {
    
    var encoding : String.Encoding
    var fileHandle : FileHandle
    
    var fieldDelimiter = ","
    var recordDelimiter = "\r\n"
    
    var escapedCharacters : CharacterSet {
        return CharacterSet(charactersIn: "\(fieldDelimiter)\(recordDelimiter)\"")
    }
    
    private func escape(string : String) -> String {
        if string.unicodeScalars.contains(where: { (char) -> Bool in
            escapedCharacters.contains(char)
        }) {
            let quotesEscaped = string.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"" + quotesEscaped + "\""
        } else {
            return string
        }
    }
    
    init(writeTo url: URL, encoding : String.Encoding) throws {
        try Data().write(to: url)
        fileHandle = try FileHandle(forWritingTo: url)
        self.encoding = encoding
    }
    
    func writeRecord(fields : [String]) {
        let escapedFields = fields.map{escape(string: $0)}
        let line = escapedFields.joined(separator: fieldDelimiter) + "\r\n"
        let lineData = line.data(using: encoding, allowLossyConversion: true)!
        fileHandle.write(lineData)
    }
    
    deinit {
        fileHandle.closeFile()
    }

}

class CSVConversionEngine: NSObject {
    

    private func recordFieldSet(forRecords records: [EventRecord]) -> Set<String> {
        return records.reduce(Set<String>(), { (accum, thisRecord) -> Set<String> in
            return accum.union(thisRecord.keys)
        })
    }
    
    private func orderedFields(forRecords records : [EventRecord]) -> [String] {
        
        let allFields = recordFieldSet(forRecords: records)
        
        let canonicalFields = [PTSessionName,
                               PTTrackName,
                               PTTrackComment,
                               PTTrackInactive,
                               PTTrackHidden,
                               PTTrackMuted,
                               PTTrackSolo,
                               PTEventNumber,
                               PTClipName,
                               PTStart,
                               PTFinish,
                                PTClipMuted]
        
        let userFields = allFields.subtracting(Set(canonicalFields))
        return canonicalFields + userFields.sorted()
    }
    
    private func row(withFields fields: [String], for record : EventRecord) -> [String] {
        return fields.map { (key) -> String in
            record[key] ?? ""
        }
    }
    
    func convert(fileURL : URL, encoding: String.Encoding, to : URL) throws {
        
        let entityParser = try PTEntityParser(url: fileURL, encoding: encoding.rawValue)
        let tabulator = SessionEntityTabulator(tracks: entityParser.tracks,
                                               markers: entityParser.markers,
                                               session: entityParser.session!)
        tabulator.interpetRecords()
        
        let records = tabulator.records
        
        let writer = try CSVWriter(writeTo: to, encoding: String.Encoding.utf8)
        let fields = orderedFields(forRecords: records)
        writer.writeRecord(fields: fields)
        records.forEach { (record) in
            writer.writeRecord(fields: row(withFields: fields, for: record) )
        }
    }
}

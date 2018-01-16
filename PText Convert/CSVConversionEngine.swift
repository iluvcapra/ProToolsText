//
//  CSVConversionEngine.swift
//  ADR Spotting
//
//  Created by Jamie Hardt on 12/23/17.
//

import Cocoa
import PKit

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
        FileManager().createFile(atPath: url.path, contents: nil, attributes: nil)
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

class CSVConversionEngine: NSObject, SessionEntityTabulatorDelegate {
    
    var records : [[String:String]] = []
    
    func rectifier(_ r: SessionEntityTabulator, didReadRecord rec: [String : String]) {
        records.append(rec)
    }
    
    private func recordFieldSet() -> Set<String> {
        return records.reduce(Set<String>(), { (accum, thisRecord) -> Set<String> in
            return accum.union(thisRecord.keys)
        })
    }
    
    private func orderedFields() -> [String] {
        
        let allFields = recordFieldSet()
        
        let canonicalFields = [PTSessionName, PTRawSessionName, PTTrackName,
                               PTRawTrackName, PTTrackComment, PTRawTrackComment,
                               PTEventNumber, PTClipName, PTRawClipName,
                               PTStart, PTFinish, PTDuration, PTMuted]
        
        let userFields = allFields.subtracting(Set(canonicalFields))
        return canonicalFields + userFields.sorted()
    }
    
    private func row(for record : [String : String]) -> [String] {
        return orderedFields().map { (key) -> String in
            record[key] ?? ""
        }
    }
    
    func convert(fileURL : URL, encoding: String.Encoding, to : URL) throws {
        
        let entityParser = try PTEntityParser(url: fileURL, encoding: encoding.rawValue)
        
        let writer = try CSVWriter(writeTo: to, encoding: String.Encoding.utf8)
        writer.writeRecord(fields: orderedFields())
        records.forEach { (record) in
            writer.writeRecord(fields: row(for: record))
        }
    }
}

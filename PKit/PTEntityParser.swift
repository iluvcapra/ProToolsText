//
//  PTEntityParser.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/23/17.
//

import Foundation
import CoreMedia

public class PTEntityParser: NSObject, PTTextFileParserDelegate {
    
    public var session : SessionEntity?
    public var markers : [MarkerEntity] = []
    public var tracks : [TrackEntity] = []
    
    private var thisTrack : TrackEntity?
    
    public init(url : URL, encoding : UInt) throws {
        super.init()
        let parser = PTTextFileParser()
        parser.delegate = self
        let data = try Data(contentsOf: url)
        try parser.parse(data: data, encoding: encoding)
    }
    
    public func parserWillBegin(_ parser : PTTextFileParser) {
        session = nil
        markers = []
        tracks = []
    }
    public func parserDidFinish(_ parser : PTTextFileParser) {}
    
    public func parser(_ parser : PTTextFileParser,
                didReadSessionHeaderWithTitle title: String,
                sampleRate : Double,
                bitDepth : String,
                startTime : String,
                timecodeFormat : String,
                trackCount : Int,
                clipsCount : Int,
                filesCount : Int) {
        session = SessionEntity(rawTitle: title, sampleRate: sampleRate,
                                bitDepth: bitDepth,
                                startTime: startTime,
                                timecodeFormat: timecodeFormat,
                                trackCount: trackCount,
                                clipCount: clipsCount,
                                filesCount: filesCount)
    }
    
    public func parser(_ parser : PTTextFileParser,
                willReadEventsForTrack name: String,
                comments: String?,
                userDelay: String,
                stateFlags: [String],
                plugins: [String]) {
        thisTrack = TrackEntity(rawTitle: name,
                                rawComment: comments ?? "",
                                solo: stateFlags.contains("Solo"),
                                mute: stateFlags.contains("Muted"),
                                active: !stateFlags.contains("Inactive"),
                                hidden: stateFlags.contains("Hidden"),
                                clips: [])
    }
    
    public func parserDidFinishReadingTrack(_ parser :PTTextFileParser) {
        if let t = thisTrack {
            tracks.append(t)
            thisTrack = nil
        }
    }
    
    public func parser(_ parser: PTTextFileParser,
                didReadEventNamed n: String,
                channel: Int,
                eventNumber: Int,
                start : String,
                end : String,
                duration : String,
                timestamp : String?,
                state: String) {
        
        if channel != 1 { return }
        
        guard let sess = session else { return }
        
        let decodedStart = (try? sess.decodeTime(from: start)) ?? CMTime.invalid
        let decodedFinish = (try? sess.decodeTime(from: end)) ?? CMTime.invalid
        let decodedTimestamp = try? sess.decodeTime(from: timestamp ?? "")
        
        let c = ClipEntity(rawName: n, eventNumber: eventNumber,
                           rawStart: start,
                           rawFinish: end,
                           rawDuration: duration,
                           rawUserTimestamp : timestamp,
                           start: decodedStart,
                           finish: decodedFinish,
                           userTimestamp: decodedTimestamp,
                           muted: state == "Unmuted" ? false : true)
        
        thisTrack!.clips.append(c)
    }
    
    public func parser(_ parser : PTTextFileParser,
                didReadMemoryLocation: Int,
                atLocation: String,
                timeReference: Int,
                units: String,
                name: String,
                comments: String?) {
        
        let m = MarkerEntity(rawName: name, rawComment: comments ?? "", rawLocation: atLocation)
        markers.append(m)
    }
}

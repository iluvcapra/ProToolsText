//
//  PTEntityParser.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/23/17.
//

import Foundation
import PKit

class PTEntityParser: NSObject, PTTextFileParserDelegate {
    
    struct SessionEntity {
        var rawTitle : String
    }
    
    struct ClipEntity {
        var rawName : String
        var eventNumber : Int
        var rawStart : String
        var rawFinish : String
        var rawDuration : String
        var muted : Bool
    }
    
    struct TrackEntity {
        var rawTitle : String
        var rawComment : String
        var clips : [ClipEntity]
    }
    
    struct MarkerEntity {
        var rawName : String
        var rawComment : String
        var rawLocation : String
    }
    
    var session : SessionEntity?
    var markers : [MarkerEntity] = []
    var tracks : [TrackEntity] = []
    
    private var thisTrack : TrackEntity?
    
    func parserWillBegin(_ parser : PTTextFileParser) {
        session = nil
        markers = []
        tracks = []
    }
    func parserDidFinish(_ parser : PTTextFileParser) {}
    
    func parser(_ parser : PTTextFileParser,
                didReadSessionHeaderWithTitle title: String,
                sampleRate : Double,
                bitDepth : String,
                startTime : String,
                timecodeFormat : String,
                trackCount : Int,
                clipsCount : Int,
                filesCount : Int) {
        session = SessionEntity(rawTitle: title)
    }
    
    func parser(_ parser : PTTextFileParser,
                willReadEventsForTrack name: String,
                comments: String?,
                userDelay: String,
                stateFlags: [String],
                plugins: [String]) {
        thisTrack = TrackEntity(rawTitle: name,
                                rawComment: comments ?? "",
                                clips: [])
    }
    
    func parserDidFinishReadingTrack(_ parser :PTTextFileParser) {
        if let t = thisTrack {
            tracks.append(t)
            thisTrack = nil
        }
    }
    
    func parser(_ parser: PTTextFileParser,
                didReadEventNamed n: String,
                channel: Int,
                eventNumber: Int,
                start : String,
                end : String,
                duration : String,
                timestamp : String?,
                state: String) {
        
        if channel != 1 { return }
        
        let c = ClipEntity(rawName: n, eventNumber: eventNumber,
                           rawStart: start, rawFinish: end, rawDuration: duration,
                           muted: state == "Unmuted" ? false : true)
        
        thisTrack!.clips.append(c)
    }
    
    func parser(_ parser : PTTextFileParser,
                didReadMemoryLocation: Int,
                atLocation: String,
                timeReference: Int,
                units: String,
                name: String,
                comments: String?) {}
}

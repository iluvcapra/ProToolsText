//
//  PTEntityParser.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/23/17.
//

import Foundation

public class PTEntityParser: NSObject, PTTextFileParserDelegate {
    
    public struct SessionEntity {
        public var rawTitle : String
        
        public init(rawTitle t : String) {
            rawTitle = t
        }
    }
    
    public struct ClipEntity {
        public var rawName : String
        public var eventNumber : Int
        public var rawStart : String
        public var rawFinish : String
        public var rawDuration : String
        public var muted : Bool
        
        public init(rawName n: String, eventNumber e: Int,
                    rawStart s: String,
                    rawFinish f: String,
                    rawDuration d: String,
                    muted m: Bool) {
            rawName = n
            eventNumber = e
            rawStart = s
            rawFinish = f
            rawDuration = d
            muted = m
            
        }
        
    }
    
    public struct TrackEntity {
        public var rawTitle : String
        public var rawComment : String
        public var clips : [ClipEntity]
        
        public init(rawTitle t : String, rawComment com: String, clips ca : [ClipEntity]) {
            rawTitle = t
            rawComment = com
            clips  = ca
        }
    }
    
    public struct MarkerEntity {
        public var rawName : String
        public var rawComment : String
        public var rawLocation : String
        
        public init(rawName n: String, rawComment c: String, rawLocation l: String) {
            rawName = n
            rawComment = c
            rawLocation = l
        }
    }
    
    public var session : SessionEntity?
    public var markers : [MarkerEntity] = []
    public var tracks : [TrackEntity] = []
    
    private var thisTrack : TrackEntity?
    
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
        session = SessionEntity(rawTitle: title)
    }
    
    public func parser(_ parser : PTTextFileParser,
                willReadEventsForTrack name: String,
                comments: String?,
                userDelay: String,
                stateFlags: [String],
                plugins: [String]) {
        thisTrack = TrackEntity(rawTitle: name,
                                rawComment: comments ?? "",
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
        
        let c = ClipEntity(rawName: n, eventNumber: eventNumber,
                           rawStart: start, rawFinish: end, rawDuration: duration,
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

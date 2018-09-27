//
//  PTEntityParser.swift
//  PText Convert
//
//  Created by Jamie Hardt on 12/23/17.
//

import Foundation
import CoreMedia

public class PTEntityParser: NSObject, PTTextFileParserDelegate {
    
    public struct SessionEntity {
        public let rawTitle : String
        public let sampleRate : Double
        public let bitDepth : String
        public let startTime : String
        public let timecodeFormat : String
        public let trackCount : Int
        public let clipCount : Int
        public let filesCount : Int
        
        public init(rawTitle : String,
                    sampleRate : Double,
                    bitDepth : String,
                    startTime : String,
                    timecodeFormat : String,
                    trackCount : Int,
                    clipCount : Int,
                    filesCount : Int) {
            self.rawTitle = rawTitle
            self.sampleRate = sampleRate
            self.bitDepth = bitDepth
            self.startTime = startTime
            self.timecodeFormat = timecodeFormat
            self.trackCount = trackCount
            self.clipCount = clipCount
            self.filesCount = filesCount
        }
    }
    
    public struct ClipEntity {
        public let rawName : String
        public let eventNumber : Int
        public let rawStart : String
        public let rawFinish : String
        public let rawDuration : String
        public let rawUserTimestamp : String?
        public let muted : Bool
        
        public let start : CMTime
        public let finish : CMTime
        public let userTimestamp : CMTime?

        public var duration : CMTime {
            return finish - start
        }
        
        
        public init(rawName n: String, eventNumber e: Int,
                    rawStart s: String,
                    rawFinish f: String,
                    rawDuration d: String,
                    rawUserTimestamp u: String?,
                    start tcStart : CMTime,
                    finish tcFinish : CMTime,
                    userTimestamp tcTimestamp : CMTime?,
                    muted m: Bool) {
            rawName = n
            eventNumber = e
            rawStart = s
            rawFinish = f
            rawDuration = d
            rawUserTimestamp = u
            muted = m
            
            start = tcStart
            finish = tcFinish
            userTimestamp = tcTimestamp
            
        }
        
//        public init(rawName n: String, eventNumber e: Int,
//                    rawStart s: String,
//                    rawFinish f: String,
//                    rawDuration d: String,
//                    rawUserTimestamp u: String?,
//                    muted m: Bool) {
//            rawName = n
//            eventNumber = e
//            rawStart = s
//            rawFinish = f
//            rawDuration = d
//            rawUserTimestamp = u
//            muted = m
//        }
//
//        public init(rawName n: String, eventNumber e: Int,
//                    rawStart s: String,
//                    rawFinish f: String,
//                    rawDuration d: String,
//                    muted m: Bool) {
//            rawName = n
//            eventNumber = e
//            rawStart = s
//            rawFinish = f
//            rawDuration = d
//            rawUserTimestamp = nil
//            muted = m
//        }
        
    }
    
    public struct TrackEntity {
        public let solo : Bool
        public let mute : Bool
        public let active : Bool
        public let hidden : Bool
        public let rawTitle : String
        public let rawComment : String
        public var clips : [ClipEntity]
        
        public init(rawTitle t : String, rawComment com: String,
                    solo : Bool, mute : Bool,
                    active : Bool, hidden : Bool,
                    clips ca : [ClipEntity]) {
            rawTitle = t
            rawComment = com
            clips  = ca
            self.solo = solo
            self.mute = mute
            self.active = active
            self.hidden = hidden
        }
    }
    
    public struct MarkerEntity {
        public let rawName : String
        public let rawComment : String
        public let rawLocation : String
        
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

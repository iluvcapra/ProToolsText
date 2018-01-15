//
//  SessionEntityRectifier.swift
//  ADR Spotting
//
//  Created by Jamie Hardt on 12/24/17.
//

import Foundation
import PKit

/*
 The SessionEntityRectifier takes parsed PTEntities and turns the lot into
 a list of dictionaries.
 - One dictionary is created for each Clip
 -
 */

protocol SessionEntityTabulatorDelegate {
    func rectifier(_ r: SessionEntityTabulator, didReadRecord : [String:String])
}

class SessionEntityTabulator {
    
    private let session : PTEntityParser.SessionEntity
    private let markers : [PTEntityParser.MarkerEntity]
    private let tracks : [PTEntityParser.TrackEntity]
    
    private var timeSpanClips : [PTEntityParser.ClipEntity] = []
    
    var delegate : SessionEntityTabulatorDelegate?
    
    private func fields(for session : PTEntityParser.SessionEntity) -> [String:String] {
        let sessionNameParse = TagParser(string: session.rawTitle).parse()
        var dict = sessionNameParse.fields
        dict[PTSessionName] = sessionNameParse.text
        dict[PTRawSessionName] = session.rawTitle
        return dict
    }
    
    private func fields(for track : PTEntityParser.TrackEntity) -> [String:String] {
        let trackNameParse = TagParser(string: track.rawTitle).parse()
        let trackCommentParse = TagParser(string : track.rawComment).parse()
        let trackDict : [String:String] = {
            var dict = trackNameParse.fields
            dict = dict.mergeKeepCurrent(trackCommentParse.fields)
            dict[PTTrackName] = trackNameParse.text
            dict[PTRawTrackName] = track.rawTitle
            dict[PTTrackComment] = trackCommentParse.text
            dict[PTRawTrackComment] = track.rawComment
            return dict
        }()
        return trackDict
    }
    
    private func fields(for clip: PTEntityParser.ClipEntity) -> [String:String] {
        let clipNameParse = TagParser(string: clip.rawName).parse()
        let clipDict : [String:String] = {
            var dict = clipNameParse.fields
            dict[PTEventNumber] = String(clip.eventNumber)
            dict[PTClipName] = clipNameParse.text
            dict[PTRawClipName] = clip.rawName
            dict[PTStart] = clip.rawStart
            dict[PTFinish] = clip.rawFinish
            dict[PTDuration] = clip.rawDuration
            dict[PTMuted] = clip.muted ? PTMuted : ""
            return dict
        }()
        return clipDict
    }
    
    private func memoryLocationFields(for clip : PTEntityParser.ClipEntity) -> [String : String] {
        let sortedMems = markers.sorted { (el, er) -> Bool in
            el.rawLocation < er.rawLocation
        }
        
        return sortedMems.reduce([:]) { (dict, thisMarker) -> Dictionary<String,String> in
            if thisMarker.rawLocation < clip.rawFinish {
                let markerNameFields = TagParser(string: thisMarker.rawName).parse().fields
                let markerCommentFields = TagParser(string: thisMarker.rawComment).parse().fields
                let markerFields = markerNameFields.mergeKeepCurrent(markerCommentFields)
                return dict.merging(markerFields, uniquingKeysWith: { (_, newVal) -> String in
                    newVal
                })
            } else {
                return dict
            }
        }
    }
    
    private func timespanFields(for clip: PTEntityParser.ClipEntity ) -> [String:String] {
        let applicable = timeSpanClips.reversed().filter {
            clip.rawStart >= $0.rawStart && clip.rawStart <= $0.rawFinish
        }
        
        return applicable.reduce([String:String](), { (dict, thisClip) -> [String:String] in
            let fields = TagParser(string: thisClip.rawName).parse().fields
            return dict.mergeKeepCurrent(fields)
        })
    }
    
    private func accumulateRecord(forClipFields clipFields: [String:String],
                        accumulatedFields : [String : String],
                        trackFields : [ String: String],
                        timespanFields : [String : String],
                        markerFields : [String : String],
                        sessionFields : [String : String] )  -> [String:String]{
        var record = accumulatedFields
            .mergeKeepCurrent(clipFields)
            .mergeKeepCurrent(trackFields)
            .mergeKeepCurrent(timespanFields)
            .mergeKeepCurrent(markerFields)
            .mergeKeepCurrent(sessionFields)
        
        if let currentClipName = clipFields[PTClipName],
            let accum = accumulatedFields[PTClipName] {
            record[PTClipName] = accum + " " + currentClipName
        } else {
            record[PTClipName] = accumulatedFields[PTClipName] ?? record[PTClipName]
        }
        record[PTFinish] = clipFields[PTFinish]
        return record
    }

    private func interpret(track : PTEntityParser.TrackEntity) {
        let trackFields = fields(for: track)
        let sessionFields = fields(for: session)
        
        var fieldAccumulator : [String:String] = [:]
        for clip in track.clips {
            if clip.rawName.hasPrefix("@") {
                timeSpanClips.append(clip)
            } else {
                let clipFields = fields(for: clip)
                let memoryLocFields = memoryLocationFields(for: clip)
                let tsFields = timespanFields(for: clip)
                
                fieldAccumulator = accumulateRecord(forClipFields: clipFields,
                                                    accumulatedFields: fieldAccumulator,
                                                    trackFields: trackFields,
                                                    timespanFields: tsFields,
                                                    markerFields: memoryLocFields,
                                                    sessionFields: sessionFields)
                
                if let apidx = fieldAccumulator.index(forKey: "AP") {
                    fieldAccumulator.remove(at: apidx)
                } else {
                    delegate?.rectifier(self, didReadRecord: fieldAccumulator)
                    fieldAccumulator = [:]
                }
            }
        }
    }
    
    func interpetRecords() {
        timeSpanClips = []
        for track in tracks {
            interpret(track:track)
        }
    }
    
    init(tracks: [PTEntityParser.TrackEntity],
         markers: [PTEntityParser.MarkerEntity],
         session: PTEntityParser.SessionEntity) {
        self.session = session
        self.markers = markers
        self.tracks = tracks
    }
}

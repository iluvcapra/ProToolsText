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

protocol SessionEntityRectifierDelegate {
    func rectifier(_ r: SessionEntityTabulator, didReadRecord : [String:String])
}

let PTSessionName       = "PT_SessionName"
let PTRawSessionName    = "PT_RawSessionName"
let PTTrackName         = "PT_TrackName"
let PTRawTrackName      = "PT_RawTrackName"
let PTTrackComment      = "PT_TrackComment"
let PTRawTrackComment   = "PT_RawTrackComment"
let PTEventNumber       = "PT_EventNumber"
let PTClipName          = "PT_ClipName"
let PTRawClipName       = "PT_RawClipName"
let PTStart             = "PT_Start"
let PTFinish            = "PT_Finish"
let PTDuration          = "PT_Duration"
let PTMuted             = "PT_Muted"

class SessionEntityTabulator {
    
    private let session : PTEntityParser.SessionEntity
    private let markers : [PTEntityParser.MarkerEntity]
    private let tracks : [PTEntityParser.TrackEntity]
    
    var delegate : SessionEntityRectifierDelegate?
    
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
            dict[PTMuted] = clip.muted ? "Muted" : ""
            return dict
        }()
        return clipDict
    }
    
    private func interpret(track : PTEntityParser.TrackEntity) {
        let trackFields = fields(for: track)
        let sessionFields = fields(for: session)
        for clip in track.clips {
            let clipFields = fields(for: clip)
            let record = clipFields.mergeKeepCurrent(trackFields).mergeKeepCurrent(sessionFields)
            delegate?.rectifier(self, didReadRecord: record)
        }
    }
    
    func interpetRecords() {
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

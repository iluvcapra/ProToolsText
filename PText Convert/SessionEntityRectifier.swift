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
    func rectifier(_ r: SessionEntityRectifier, didReadRecord : [String:String])
}


class SessionEntityRectifier {
    
    private let session : PTEntityParser.SessionEntity
    private let markers : [PTEntityParser.MarkerEntity]
    private let tracks : [PTEntityParser.TrackEntity]
    
    var delegate : SessionEntityRectifierDelegate?
    
    private func fields(for track : PTEntityParser.TrackEntity) -> [String:String] {
        let trackNameParse = TagParser(string: track.rawTitle).parse()
        let trackCommentParse = TagParser(string : track.rawComment).parse()
        let trackDict : [String:String] = {
            var dict = trackNameParse.fields
            dict = dict.mergeKeepCurrent(trackCommentParse.fields)
            dict["TrackName"] = trackNameParse.text
            dict["RawTrackName"] = track.rawTitle
            dict["TrackComment"] = trackCommentParse.text
            dict["RawTrackComment"] = track.rawComment
            return dict
        }()
        return trackDict
    }
    
    private func fields(for clip: PTEntityParser.ClipEntity) -> [String:String] {
        let clipNameParse = TagParser(string: clip.rawName).parse()
        let clipDict : [String:String] = {
            var dict = clipNameParse.fields
            dict["EventNumber"] = String(clip.eventNumber)
            dict["ClipName"] = clipNameParse.text
            dict["RawClipName"] = clip.rawName
            dict["Start"] = clip.rawStart
            dict["Finish"] = clip.rawFinish
            dict["Duration"] = clip.rawDuration
            dict["Muted"] = clip.muted ? "Muted" : ""
            return dict
        }()
        return clipDict
    }
    
    private func interpret(track : PTEntityParser.TrackEntity) {
        let trackFields = fields(for: track)
        
        for clip in track.clips {
            let clipFields = fields(for: clip)
            let record = clipFields.mergeKeepCurrent(trackFields)
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

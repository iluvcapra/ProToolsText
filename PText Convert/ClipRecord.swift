//
//  File.swift
//  PText Convert
//
//  Created by Jamie Hardt on 1/14/18.
//

import Foundation
import PKit


let PTSessionName       = "PT_SessionName"
let PTRawSessionName    = "PT_RawSessionName"
let PTTrackName         = "PT_TrackName"
let PTTrackIndex        = "PT_TrackIndex"
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

let AppendingField      = "AP"

public struct ClipRecord {
    public var sessionName : String
    public var trackName : String
    public var trackComment : String
    public var trackIndex : Int
    public var eventNumber : Int
    public var clipName : String
    public var start : String
    public var finish : String
    public var muted : Bool
    public var userData : [String:String] = [:]
    
    
    public static func from(tracks : [PTEntityParser.TrackEntity],
                            markers : [PTEntityParser.MarkerEntity],
                            session : PTEntityParser.SessionEntity) -> [ClipRecord] {

        let records = tracks.enumerated().flatMap { (offset, track) -> [ClipRecord] in
            let simpleRecords = ClipRecord.from(track: track, trackIndex: offset, session: session)
            
            
            return simpleRecords
        }
        
        
    }
    
    public static func from(track : PTEntityParser.TrackEntity,
                            trackIndex : Int,
                            session : PTEntityParser.SessionEntity) -> [ClipRecord] {
        return track.clips.map({ (clip) -> ClipRecord in
            return ClipRecord(sessionName: session.rawTitle,
                              trackName: track.rawTitle,
                              trackComment: track.rawComment,
                              trackIndex: trackIndex,
                              eventNumber: clip.eventNumber,
                              clipName: clip.rawName,
                              start: clip.rawStart,
                              finish: clip.rawFinish,
                              muted: clip.muted, userData: [:])
        })
    }
    
    /**
     Appends `clipRecord` to this `ClipRecord`, mergeing the `userDatas`, appending the clip names and setting
     the receiver's end time to the argument's
     */
    public func appended(clipRecord : ClipRecord) -> ClipRecord  {
        var retVal = self
        retVal.userData = userData.mergeKeepCurrent(clipRecord.userData)
        retVal.clipName = [clipName, clipRecord.clipName].joined(separator: " ")
        retVal.finish = clipRecord.finish
        return retVal
    }
    
    public func toDict() -> [String:String] {
        return [
            PTSessionName : sessionName,
            PTTrackName : trackName,
            PTTrackComment : trackComment,
            PTEventNumber : String(eventNumber),
            PTClipName : clipName,
            PTStart : start,
            PTFinish : finish,
            PTMuted : muted ? PTMuted : "",
        ].mergeKeepCurrent(userData)
    }
    
    /// applies fields in clip, track and session entities with the standard precedence
    mutating func applyFieldsCanonically() {
        applyClipNameFields()
        applyTrackCommentFields()
        applyTrackNameFields()
        applySessionNameFields()
    }
    
    /**
     Applies fields in `sessionName` to `userData`. The session name is
     then set to the untagged prefixing portion of `sessionName`.
     */
    mutating func applySessionNameFields() {
        let result = TagParser(string: sessionName).parse()
        sessionName = result.text
        userData = userData.mergeKeepCurrent(result.fields)
    }
    
    mutating func applyTrackCommentFields() {
        let result = TagParser(string: trackComment).parse()
        trackComment = result.text
        userData = userData.mergeKeepCurrent(result.fields)
    }
    
    mutating func applyTrackNameFields() {
        let result = TagParser(string: trackName).parse()
        trackName = result.text
        userData = userData.mergeKeepCurrent(result.fields)
    }
    
    /**
     Applies fields in clip name to `userData`. The clip name is
     then set to the unparsed prefixing portion of `clipName`.
     */
    mutating func applyClipNameFields() {
        let p = TagParser(string: clipName)
        let result = p.parse()
        applyToUserData(result.fields)
        clipName = result.text
    }
    
    /// merges the given dictionary with `userData`, keeping the
    /// values of exisiting keys where they exist.
    mutating func applyToUserData(_ dict : [String:String]) {
        userData = userData.mergeKeepCurrent(dict)
    }
}

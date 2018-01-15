//
//  File.swift
//  PText Convert
//
//  Created by Jamie Hardt on 1/14/18.
//

import Foundation
import PKit

public struct ClipRecord {
    public var sessionName : String
    public var trackName : String
    public var trackComment : String
    public var eventNumber : Int
    public var clipName : String
    public var start : String
    public var finish : String
    public var muted : Bool
    public var userData : [String:String] = [:]
    
    public static func from(clip : PTEntityParser.ClipEntity,
                     track: PTEntityParser.TrackEntity,
                     session : PTEntityParser.SessionEntity ) -> ClipRecord {
        return ClipRecord(sessionName: session.rawTitle,
                          trackName: track.rawTitle,
                          trackComment: track.rawComment,
                          eventNumber: clip.eventNumber,
                          clipName: clip.rawName,
                          start: clip.rawStart, finish:
                            clip.rawFinish,
                          muted: clip.muted, userData: [:])
    }
    
    /// applies fields in clip, track and session entities with the standard precedence
    mutating func applyFieldsCanonically() {
        applyClipNameFields()
        applyTrackCommentFields()
        applyTrackNameFields()
        applySessionNameFields()
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
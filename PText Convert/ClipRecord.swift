//
//  File.swift
//  PText Convert
//
//  Created by Jamie Hardt on 1/14/18.
//

import Foundation

struct ClipRecord {
    var sessionName : String
    var trackName : String
    var trackComment : String
    var eventNumber : Int
    var clipName : String
    var start : String
    var finish : String
    var duration : String
    var muted : Bool
    var userData : [String:String]
}

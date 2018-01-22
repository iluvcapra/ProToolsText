//
//  ADRLine.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 1/21/18.
//

import Cocoa

class ADRLine: NSObject {

    let SupervisorKey = "super"
    let ClientKey = "client"
    
    let CueNumberKey = "qn"
    let ActorNameKey = "act"
    let SceneKey = "sc"
    let MinPerLine = "mpl"
    let NoteKey = "note"
    let ReasonKey = "r"
    
    
    var title : String?
    var supervisor : String?
    var client : String?
    
    var cueNumber : String?
    var scene : String?
    
    var dialogue : String?
    var characterName : String?
    var actorName : String?
    var timeBudget : TimeInterval?
    
    var start : String?
    var finish : String?
    
    var reason : String?
    var note : String?
    
    init(with dictionary : [String:String]) {
        
        title = dictionary[PTSessionName]
        supervisor = dictionary[SupervisorKey]
        client = dictionary[ClientKey]
        
        dialogue = dictionary[PTClipName]
        characterName = dictionary[PTTrackName]
        actorName = dictionary[ActorNameKey]
        if let mpl = dictionary[MinPerLine], let mins = Double(mpl) {
            timeBudget = mins * TimeInterval(60.0)
        }
        
        cueNumber = dictionary[CueNumberKey]
        scene = dictionary[SceneKey]
        
        start = dictionary[PTStart]
        finish = dictionary[PTFinish]
        
        reason = dictionary[ReasonKey]
        note = dictionary[NoteKey]
        
        super.init()
    }
}

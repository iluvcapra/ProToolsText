//
//  ADRLine.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 1/21/18.
//

import Cocoa

struct ADRLineValidationFailure {
    var element : Int
    var description : String
    var line : ADRLine
}

//extension Sequence {
//    func sequenceWithIndex() -> Sequence<(Int,Element)> {
//        return zip((0...), self)
//    }
//}


extension Sequence where Element == ADRLine {
    
    func validateNoEmptyTimes() -> [ADRLineValidationFailure] {
        return zip((0...), self).flatMap({ (index, line) -> ADRLineValidationFailure? in
            if let _ = line.start, let _ = line.finish {
                return nil
            } else {
                return ADRLineValidationFailure(element: index,
                                                description: "Missing start or finish time",
                                                line : line)
            }
        })
    }
    
    func validateNoEmptyCueNumbers() -> [ADRLineValidationFailure] {
        return zip((0...), self).flatMap({ (index, line) -> ADRLineValidationFailure? in
            if let _ = line.cueNumber {
                return nil
            } else {
                return ADRLineValidationFailure(element: index,
                                                description: "Missing cue number",
                                                line : line)
            }
        })
    }
    
    func validateCueNumber() -> [ADRLineValidationFailure] {
        
    }

    func validateADRLines() {
        let errors = validateNoEmptyCueNumbers() + validateNoEmptyTimes() + validateCueNumbersUnique()
    }
    
    func xmlDocument() -> XMLDocument {
        let rootElement = XMLElement(name: "ADR_LOG")
        
        forEach { line in
            let lineNode = XMLElement(name: "line")
            
            let elementMap = [
                "title" : \ADRLine.title,
                "supervisor" : \ADRLine.supervisor,
                "client" : \ADRLine.client,
                "reel"  : \ADRLine.reel,
                "version" : \ADRLine.version,
                "dialogue" : \ADRLine.dialogue,
                "character" : \ADRLine.characterName,
                "actor" : \ADRLine.actorName,
                "start" : \ADRLine.start,
                "finish" : \ADRLine.finish,
                "reason" : \ADRLine.reason,
                "effort" : \ADRLine.isEffort,
                "note" : \ADRLine.note,
                "priority" : \ADRLine.priority,
                "shoot_date" : \ADRLine.shootDate,
                "broadcast-alt" : \ADRLine.isTV,
                "to-be-written" : \ADRLine.isTBW
                ]
            
            for (key, kp) in elementMap {
                
                switch kp {
                case let path as KeyPath<ADRLine,String?>:
                    lineNode.addChild(XMLElement(name: key, stringValue: line[keyPath: path]))
                case let path as KeyPath<ADRLine,Int?>:
                    if let intVal = line[keyPath:path] {
                        lineNode.addChild(XMLElement(name: key, stringValue: String(intVal)))
                    }
                case let path as KeyPath<ADRLine,TimeInterval?>:
                    if let tVal = line[keyPath:path] {
                        lineNode.addChild(XMLElement(name: key, stringValue: String(tVal)))
                    }
                case let path as KeyPath<ADRLine,Bool>:
                    if line[keyPath : path] {
                        lineNode.addChild(XMLElement(name: key))
                    }
                default:
                    break
                }
                
            }

            rootElement.addChild(lineNode)
        }
        
        return XMLDocument(rootElement: rootElement)
    }
}

struct ADRLine: Codable {
    
    var title : String?
    var supervisor : String?
    var client : String?
    
    var cueNumber : String?
    var scene : String?
    var reel : String?
    var version : String?

    var dialogue : String?
    var characterName : String?
    var actorName : String?
    var timeBudget : TimeInterval?
    
    var priority : Int?
    
    var start : String?
    var finish : String?
    
    var reason : String?
    var note : String?
    
    var shootDate : String?
    
    var isEffort : Bool
    var isTV : Bool
    var isTBW : Bool
}

extension ADRLine {
    
    init(with dictionary : [String:String]) {
        
        let TitleKey = "title"
        let SupervisorKey = "super"
        let ClientKey = "client"
        
        let ReelKey = "reel"
        let VersionKey = "v"
        
        let PriorityKey = "p"
        
        let CueNumberKey = "qn"
        let ActorNameKey = "act"
        let SceneKey = "sc"
        let MinPerLine = "mpl"
        let NoteKey = "note"
        let ReasonKey = "r"
        let EffortKey = "eff"
        let TVLineKey = "tv"
        let TBWLineKey = "tbw"
        
        title = dictionary[TitleKey] ?? dictionary[PTSessionName]
        supervisor = dictionary[SupervisorKey]
        client = dictionary[ClientKey]
        
        dialogue = dictionary[PTClipName]
        characterName = dictionary[PTTrackName]
        actorName = dictionary[ActorNameKey]
        if let mpl = dictionary[MinPerLine], let mins = Double(mpl) {
            timeBudget = mins * TimeInterval(60.0)
        }
        
        reel = dictionary[ReelKey]
        version = dictionary[VersionKey]
        
        if let p = dictionary[PriorityKey] {
            priority = Int(p)
        }

        
        cueNumber = dictionary[CueNumberKey]
        scene = dictionary[SceneKey]
        
        start = dictionary[PTStart]
        finish = dictionary[PTFinish]
        
        reason = dictionary[ReasonKey]
        note = dictionary[NoteKey]
        isEffort = dictionary.keys.contains(EffortKey)
        isTV = dictionary.keys.contains(TVLineKey)
        isTBW = dictionary.keys.contains(TBWLineKey)
    }
}

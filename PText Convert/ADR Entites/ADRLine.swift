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
    
    func validateCueNumbersUnique() -> [ADRLineValidationFailure] {
        let numberSet = NSCountedSet(array: self.flatMap { $0.cueNumber })
        
        return zip((0...), self).flatMap { (index, line) -> ADRLineValidationFailure? in
            if let number = line.cueNumber, numberSet.count(for: number) > 0 {
                return ADRLineValidationFailure(element: index, description: "Indistinct cue number", line: line)
            } else {
                return nil
            }
        }
    }

    func validateADRLines() -> [ADRLineValidationFailure] {
        return validateNoEmptyCueNumbers() +
            validateNoEmptyTimes() +
            validateCueNumbersUnique()
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
    var isOmitted : Bool
}

extension ADRLine {
    
    init(with dictionary : [String:String]) {
        
        let TitleKey = "title"
        let SupervisorKey = "super"
        let ClientKey = "client"
        
        let ReelKey = "reel"
        let VersionKey = "v"
        
        let PriorityKey = "P"
        
        let CueNumberKey = "Qn"
        let ActorNameKey = "Act"
        let SceneKey = "Sc"
        let MinPerLine = "mpl"
        let NoteKey = "note"
        let ReasonKey = "R"
        let EffortKey = "EFF"
        let TVLineKey = "TV"
        let TBWLineKey = "TBW"
        let OmittedKey = "OMIT"
        
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
        isOmitted = dictionary.keys.contains(OmittedKey)
    }
    
    func xmlElement() -> XMLElement {
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
            "omitted" : \ADRLine.isOmitted,
            "priority" : \ADRLine.priority,
            "shoot_date" : \ADRLine.shootDate,
            "broadcast-alt" : \ADRLine.isTV,
            "to-be-written" : \ADRLine.isTBW
        ]
        
        for (key, kp) in elementMap {
            
            switch kp {
            case let path as KeyPath<ADRLine,String?>:
                lineNode.addChild(XMLElement(name: key, stringValue: self[keyPath: path]))
            case let path as KeyPath<ADRLine,Int?>:
                if let intVal = self[keyPath:path] {
                    lineNode.addChild(XMLElement(name: key, stringValue: String(intVal)))
                }
            case let path as KeyPath<ADRLine,TimeInterval?>:
                if let tVal = self[keyPath:path] {
                    lineNode.addChild(XMLElement(name: key, stringValue: String(tVal)))
                }
            case let path as KeyPath<ADRLine,Bool>:
                if self[keyPath : path] {
                    lineNode.addChild(XMLElement(name: key))
                }
            default:
                break
            }
        }
        
        return lineNode
    }
}

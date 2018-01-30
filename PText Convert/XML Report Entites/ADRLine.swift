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
            if let number = line.cueNumber, numberSet.count(for: number) > 1 {
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

struct ADRLine {
    
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
    
    var userData : [String: String]
}

extension ADRLine {
    
    static func with( dictionary : [String:String]) -> ADRLine {
        
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
        
        let tagMap = [
            TitleKey : \ADRLine.title,
            SupervisorKey : \ADRLine.supervisor,
            ClientKey : \ADRLine.client,
            ReelKey : \ADRLine.reel,
            VersionKey : \ADRLine.version,
            PriorityKey : \ADRLine.priority,
            CueNumberKey : \ADRLine.cueNumber,
            ActorNameKey : \ADRLine.actorName,
            SceneKey : \ADRLine.scene,
            MinPerLine : \ADRLine.timeBudget,
            NoteKey : \ADRLine.note,
            ReasonKey : \ADRLine.reason,
            EffortKey : \ADRLine.isEffort,
            TVLineKey : \ADRLine.isTV,
            TBWLineKey : \ADRLine.isTBW,
            OmittedKey : \ADRLine.isOmitted
        ]
        
        var retVal = ADRLine(title: dictionary[PTSessionName],
                             supervisor: nil,   client: nil,    cueNumber: nil,
                             scene: nil,        reel: nil,      version: nil,
                             dialogue: dictionary[PTClipName],
                             characterName: dictionary[PTTrackName],
                             actorName: nil,
                             timeBudget: nil,
                             priority: nil,
                             start: nil, finish: nil, reason: nil, note: nil,
                             shootDate: nil, isEffort: false, isTV: false, isTBW: false, isOmitted: false,
                             userData: [:])

        
        for (userKey, path) in tagMap {
            if let value = dictionary[userKey] {
                switch (path) {
                case let strPath as WritableKeyPath<ADRLine,String?>:
                    retVal[keyPath: strPath] = value
                case let boolPath as WritableKeyPath<ADRLine,Bool?>:
                    retVal[keyPath: boolPath] = value.isEmpty ? false : true
                case let intPath as WritableKeyPath<ADRLine,Int?>:
                    retVal[keyPath: intPath] = Int(value)
                case let (tvPath) as WritableKeyPath<ADRLine,TimeInterval?>:
                    guard let sec = TimeInterval(value) else { break }
                    retVal[keyPath: tvPath] = sec * TimeInterval(60.0)
                default: break
                }
            }
        }
        
        retVal.userData = dictionary.filter{(key:String, _: String) -> Bool in
            !dictionary.keys.contains(key)
        }
        
        return retVal
    }
    
    func xmlElement() -> XMLElement {
        
        
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
        
        let lineNode = XMLElement(name: "adr-line")
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

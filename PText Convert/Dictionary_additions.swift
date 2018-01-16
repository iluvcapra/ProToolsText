//
//  Dictionary_additions.swift
//  PText Convert
//
//  Created by Jamie Hardt on 1/14/18.
//

import Foundation

extension Dictionary {
    func mergeKeepCurrent(_ other : Dictionary<Key,Value>) -> Dictionary<Key, Value> {
        return self.merging(other, uniquingKeysWith: { (current, _) -> Value in current} )
    }
}


extension Sequence where Element: Comparable {
    
    /**
     Returns a sorted list, with `prefix` elements always first
     */
    func sorted(prefix : [Element]) -> [Element] {
        return prefix + (sorted().filter { !prefix.contains($0) })
    }
}

extension Sequence where Element == Dictionary<String,Any> {
    
    /// Returns the unique keys of every dictionary in the sequence, sorted.
    func collatedKeys() -> [String] {
        let keys = self.flatMap {$0.keys}
        return Set(keys).sorted()
    }
    
    /// Returns the unique keys of every dictionary in the sequence, sorted with `prefix` elements first.
    func collatedKeys(prefix : [String]) -> [String] {
        let keys = self.flatMap {$0.keys}
        return Set(keys).sorted(prefix: prefix)
    }
    
    /// Returns the sorted values of each dict, in the order of `collatedKeys()`. Where a key does not exist, a nil is
    /// substituted.
    func collatedValues() -> [[Any?]] {
        return map { (dict) -> [Any?] in
            collatedKeys().map { dict[$0] ?? nil }
        }
    }
    
    /// Returns the sorted values of each dict, in the order of `collatedKeys(prefix:)`. Where a key does not exist, a nil is
    /// substituted.
    func collatedValues(prefixKeys : [String] ) -> [[Any?]] {
        return map { (dict) -> [Any?] in
            collatedKeys(prefix: prefixKeys).map { dict[$0] ?? nil }
        }
    }
   }

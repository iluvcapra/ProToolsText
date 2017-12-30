//
//  JHScanner.swift
//  ProToolsText
//
//  Created by Jamie Hardt on 12/28/17.
//

import Foundation


/**
 A JHScanner scans a geneirc collection of unicode scalar values, such as a `unicodeScalarView`
 on a string. The object of the scanner is to provide an interface that's easier to use and more
 general than `Scanner`.
 
 Shamelessly cribbed from [mattgallagher][1].
 
 [1]: https://github.com/mattgallagher/CwlDemangle/blob/master/CwlDemangle/CwlDemangle.swift
 */
public class JHScanner<C:Collection> where C.Iterator.Element == UnicodeScalar {
    private let scalars : C
    private var consumed: Int
    var offset: C.Index
    
    struct ExpectFailedError : Error {
        var expected : String
        var offset : Int
    }
    
    struct AtEndError : Error { }
    
    private struct State {
        var consumed : Int
        var offset : C.Index
    }
    
    var remainder : C.SubSequence {
        return scalars[offset..<scalars.endIndex]
    }
    
    /// `true` if the scalar collection has been consumed
    var atEnd : Bool {
        return scalars.endIndex == offset
    }
    
    /// Create a new scanner with collection `s`.
    /// - parameter s: A collection of `UnicodeScalar`s.
    init(scalars s: C) {
        scalars = s
        offset = scalars.startIndex
        self.consumed = 0
    }
    
    private func saveState() -> State {
        return State(consumed: consumed, offset: offset)
    }
    
    private func restoreState(_ state : State) {
        self.consumed = state.consumed
        self.offset = state.offset
    }
    
    private func advance()  {
        guard !atEnd else {
            return
        }
        offset = scalars.index(after: offset)
        consumed += 1
    }
    
    /// Returns true if the character at the present index is `scalar`,
    /// otherwise returns false.
    ///
    /// If `atEnd` is true, this returns false
    func accept(scalar : UnicodeScalar) -> Bool {
        if atEnd { return false }
        if scalars[offset] == scalar {
            advance()
            return true
        } else {
            return false
        }
    }
    
    /// Gives the present character without advancing the scanner.
    ///
    func peek() -> UnicodeScalar? {
        if atEnd {
            return nil
        } else {
            return scalars[offset]
        }
    }
    
    func expectAny() throws -> UnicodeScalar {
        try expectMore()
        let retChar = scalars[offset]
        advance()
        return retChar
    }
    
    func expectPeek() throws -> UnicodeScalar {
        try expectMore()
        return peek()!
    }
    
    /// Throws `JHScanner.AtEndError` if the scanner has exhausted the collection.
    func expectMore() throws {
        if atEnd {
            throw AtEndError()
        }
    }
    
    /// Throws if the character at the present index is `scalar`, throws
    /// under all other conditions.
    func expect(scalar : UnicodeScalar) throws {
        try expectMore()
        if accept(scalar: scalar) {
            return
        } else {
            throw ExpectFailedError(expected: String(scalar), offset: consumed)
        }
    }
    
    /// Reads until `isTrue` returns `false` and returns the string of read characters. Hitting the
    /// end before seeing `scalar` is an error.
    func readWhile(isTrue : (UnicodeScalar) -> Bool) throws -> String {
        var read = ""
        repeat {
            let this = try expectPeek()
            if isTrue(this) {
                read.append(Character(this))
                advance()
            } else {
                break
            }
        } while true
        
        return read
    }
    
    func skipWhile(isTrue : (UnicodeScalar) -> Bool) throws  {
        repeat {
            let this = try expectPeek()
            if isTrue(this) {
                advance()
            } else {
                break
            }
        } while true
        
    }
    
    /// Reads until `scalar` and returns the string of read characters. Hitting the
    /// end before seeing `scalar` is an error.
    func readUpTo(scalar : UnicodeScalar) throws -> String {
        return try readWhile { $0 != scalar }
    }
    
    /// Skip all characters up to `scalar`. Hitting the
    /// end before seeing `scalar` is an error. Upon return, the scanner is advanced
    /// past `scalar`.
    func skipUpTo(scalar : UnicodeScalar) throws {
        try skipWhile { $0 != scalar }
    }
    
    func readWhile(characters : CharacterSet) throws -> String {
        return try readWhile { characters.contains($0)}
    }
    
    func skipWhile(characters : CharacterSet) throws  {
        try skipWhile { characters.contains($0)}
    }
    
    /// Saves the state of the scanner and runs the block. If the block
    /// returns false, the state of the scanner is restored, rewinding any scanning
    /// done within `block`.
    ///
    /// If `block` throws an error, `lookahead` will simply return `false`. More granular
    /// error handling should be done within `block`.
    /// - parameter block   : Scanning in the block will be unwound if this block returns `false`
    ///             or an error is thrown
    /// - returns : Propagates the return value of `block`
    func lookahead(with block: () throws  -> Bool) -> Bool {
        let begin = saveState()
        do {
            if try block() {
                return true
            } else {
                restoreState(begin)
                return false
            }
        } catch {
            restoreState(begin)
            return false
        }

    }
    
    func accept(string : String)  -> Bool {
        return lookahead {
            for this in string.unicodeScalars {
                if !accept(scalar: this) {
                    return false
                }
            }
            return true
        }
    }
    
    func expect(string : String ) throws {
        if accept(string: string) {
            return
        } else {
            if atEnd {
                throw AtEndError()
            } else {
                throw ExpectFailedError(expected: string, offset: consumed)
            }
        }
    }
}

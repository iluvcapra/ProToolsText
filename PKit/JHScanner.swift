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
    public var consumed: Int
    private var offset: C.Index
    
    public struct ExpectFailedError : Error {
        var expected : String
        var offset : Int
    }
    
    public struct AtEndError : Error { }
    
    private struct State {
        var consumed : Int
        var offset : C.Index
    }
    
    public var remainder : C.SubSequence {
        return scalars[offset..<scalars.endIndex]
    }
    
    /// `true` if the scalar collection has been consumed
    public var atEnd : Bool {
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
    
    /** The basis the "accept" pattern. Returns the result of `ifTrue && !atEnd`
     */
    public func accept(ifTrue : (Unicode.Scalar) -> Bool ) -> Bool {
        if atEnd { return false }
        if ifTrue(scalars[offset]) {
            advance()
            return true
        } else {
            return false
        }
    }
    
    /// Returns true if the character at the present index is `scalar`,
    /// otherwise returns false.
    ///
    /// If `atEnd` is true, this returns false
    public func accept(scalar : UnicodeScalar) -> Bool {
        return accept { scalar == $0 }
    }
    
    /// Gives the present character without advancing the scanner.
    ///
    public func peek() -> UnicodeScalar? {
        if atEnd {
            return nil
        } else {
            return scalars[offset]
        }
    }
    
    public func expectAny() throws -> UnicodeScalar {
        try expectMore()
        let retChar = scalars[offset]
        advance()
        return retChar
    }
    
    public func expectPeek() throws -> UnicodeScalar {
        try expectMore()
        return peek()!
    }
    
    /// Throws `JHScanner.AtEndError` if the scanner has exhausted the collection.
    public func expectMore() throws {
        if atEnd {
            throw AtEndError()
        }
    }
    
    /// Throws if the character at the present index is `scalar`, throws
    /// under all other conditions.
    public func expect(scalar : UnicodeScalar) throws {
        try expectMore()
        if accept(scalar: scalar) {
            return
        } else {
            throw ExpectFailedError(expected: String(scalar), offset: consumed)
        }
    }
    
    /// Reads until `isTrue` returns `false` and returns the string of read characters.
    /// If the collection is at the end, the empty string is returned.
    public func readWhile(isTrue : (UnicodeScalar) -> Bool) -> String {
        var read = ""
        repeat {
            guard let this = peek() else { break }
            if isTrue(this) {
                read.append(Character(this))
                advance()
            } else {
                break
            }

        } while true
        
        return read
    }
    
    public func skipWhile(isTrue : (UnicodeScalar) -> Bool)  {
        repeat {
            guard let this = peek() else { return }
            if isTrue(this) {
                advance()
            } else {
                break
            }
        } while true
    }
    
    /// Reads until `scalar` and returns the string of read characters. Hitting the
    /// end before seeing `scalar` is an error.
    public func readUpTo(scalar : UnicodeScalar) -> String {
        return  readWhile { $0 != scalar }
    }
    
    /// Skip all characters up to `scalar`. Hitting the
    /// end before seeing `scalar` is an error. Upon return, the scanner is advanced
    /// past `scalar`.
    public func skipUpTo(scalar : UnicodeScalar) {
        skipWhile { $0 != scalar }
    }

    public func readWhile(characters : CharacterSet) -> String {
        return readWhile { characters.contains($0)}
    }
    
    public func skipWhile(characters : CharacterSet)  {
        skipWhile { characters.contains($0)}
    }
    
    /**
     Saves the state of the scanner and runs the block. If the block
     returns false, the state of the scanner is restored, rewinding any scanning
     done within `block`.
     
     If `block` throws an error, `lookahead` will simply return `false`. More granular
     error handling should be done within `block`.
     
     - parameter block   :  Scanning in the block will be unwound if this block returns `false`
                            or an error is thrown
     - returns : The return value of `block` && block returned without error
     */
    public func lookahead(with block: () throws -> Void) -> Bool {
        let begin = saveState()
        do {
            try block()
            return true
        } catch {
            restoreState(begin)
            return false
        }
    }
    
    public func accept(characterfromSet set : CharacterSet) -> Bool {
        return accept { set.contains($0) }
    }
    
    public func expect(characterfromSet set : CharacterSet ) throws {
        try expectMore()
        if !accept(characterfromSet: set) {
            throw ExpectFailedError(expected: set.description, offset: consumed)
        }
    }
    
    public func accept(string : String)  -> Bool {
        return lookahead {
            for this in string.unicodeScalars {
                try expect(scalar: this)
            }
        }
    }
    
    public func expect(string : String ) throws {
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

public extension JHScanner where C == String.UnicodeScalarView {
    convenience init(string : String) {
        self.init(scalars: string.unicodeScalars)
    }
}

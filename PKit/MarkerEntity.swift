//
//  MarkerEntity.swift
//  PKit
//
//  Created by Jamie Hardt on 4/7/19.
//

import Foundation

public struct MarkerEntity {
    public let rawName : String
    public let rawComment : String
    public let rawLocation : String
    
    public init(rawName n: String, rawComment c: String, rawLocation l: String) {
        rawName = n
        rawComment = c
        rawLocation = l
    }
}

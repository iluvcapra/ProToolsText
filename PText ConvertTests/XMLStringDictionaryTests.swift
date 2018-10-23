//
//  XMLStringDictionaryTests.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 1/29/18.
//

import XCTest
@testable import PText_Convert

class XMLStringDictionaryTests: XCTestCase {

    let input = [ "" : "Test",
                  "val" : "this",
                  "012" : "omega",
                  "xml_file" : "filename",
                  "$walla" : "Bango",
                  "Xml_Datum" : ""
    ]
    
    func testCompleteness() {
        let element = input.toXMLElement(named: "test")
        
        XCTAssertNotNil(element)
        XCTAssertEqual(element.childCount, input.count)
    }

}

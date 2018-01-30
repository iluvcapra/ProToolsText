//
//  XMLStringDictionaryTests.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 1/29/18.
//

import XCTest

class XMLStringDictionaryTests: XCTestCase {

    func testNameSanatizer() {
        
        let input = [ "" : "Test",
                      "val" : "this",
                      "012" : "omega",
                      "xml_file" : "filename",
                      "$walla" : "Bango"
        ]
        
        let element = input.toXMLElement(named: "test")
        
        XCTAssertNotNil(element)
        XCTAssertEqual(element!.childCount, 5)
        
        let names = element!.children!.map({ (n) -> String in
            n.name!
        })
        
        XCTAssertTrue(names.contains("_null"))
        XCTAssertTrue(names.contains("val"))
        XCTAssertTrue(names.contains("_012"))
        XCTAssertTrue(names.contains("_xml_file"))
        XCTAssertTrue(names.contains("_walla"))
    }


}

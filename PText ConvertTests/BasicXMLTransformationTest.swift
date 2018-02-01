//
//  BasicXMLTransformationTest.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 1/31/18.
//

import XCTest

class BasicXMLTransformationTest: XCTestCase {

    let input = """
<?xml version="1.0"?>
<pttext>
    <producer_identifer>com.soundepartment.PText-Convert</producer_identifer>
    <producer_version>0.2.2</producer_version>
    <events>
        <event>
            <field>
            <key>A</key>
            <value>100</value>
            </field>
            <field>
<key>PT.Clip.Start</key>
<value>01:00:00:00</value>
            </field>
            <field>
<key>PT.Clip.Finish</key>
<value>01:00:00:10</value>
            </field>
        </event>
    </events>
</pttext>
"""

    let xslUrl = Bundle.main.url(forResource: "Basic", withExtension: "xsl")!
    
    func testCommonElements() {
        let doc = try! XMLDocument(xmlString: input, options: XMLNode.Options.documentValidate )
        var output : Any? = nil
        
        XCTAssertNoThrow( output = try doc.objectByApplyingXSLT(at: xslUrl, arguments: nil) )
        
        guard let xmlOutput = output as? XMLDocument else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(xmlOutput.rootElement()?.name, "pttext")
        guard let tl = xmlOutput.rootElement()?.elements(forName: "producer_identifer"),
        let tl2 = xmlOutput.rootElement()?.elements(forName: "producer_version") else {
            XCTFail()
            return
        }
        XCTAssertEqual(tl.count ,1)
        XCTAssertEqual(tl2.count, 1)
        
    }

    func testEventsList() {
        let doc = try! XMLDocument(xmlString: input, options: XMLNode.Options.documentValidate )
        var output : Any? = nil
        
        XCTAssertNoThrow( output = try doc.objectByApplyingXSLT(at: xslUrl, arguments: nil) )
        
        guard let xmlOutput = output as? XMLDocument else {
            XCTFail()
            return
        }
        do {
            let events = try xmlOutput.nodes(forXPath: "pttext/events/event")
            
            XCTAssertEqual(events.count, 1)
            
            let startfields = try events[0].nodes(forXPath: "start")
            XCTAssertEqual(startfields.count, 1)
            
            let finishFields = try events[0].nodes(forXPath: "finish")
            XCTAssertEqual(finishFields.count, 1)
            
        } catch _ {
            XCTFail()
        }
        
    }

}

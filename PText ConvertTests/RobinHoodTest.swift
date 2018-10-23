//
//  RobinHoodTest.swift
//  PText ConvertTests
//
//  Created by Jamie Hardt on 10/23/18.
//

import XCTest
@testable import PText_Convert

class RobinHoodTest: XCTestCase {

    static let robinHoodURL : URL = Bundle(for: RobinHoodTest.self).url(forResource: "Robin Hood Spotting", withExtension: "txt")!
    
    var document : XMLDocument? = nil
    
    override func setUp() {
        let engine = XMLConversionEngine()
        engine.stylesheet = .structured
        
        let outputData = try! engine.convert(fileURL: RobinHoodTest.robinHoodURL)
        document = try! XMLDocument(data: outputData, options: [])
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTitle() {
        let path = "//spotting-notes/title"
        
        do {
            guard let result = try document?.rootElement()?.nodes(forXPath: path) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(result.count, 1)
            
            let title = try result[0].nodes(forXPath: "title")[0].stringValue
            let supervisor = try result[0].nodes(forXPath: "supervisor")[0].stringValue
            
            XCTAssertEqual(title, "The Adventures of Robin Hood")
            XCTAssertEqual(supervisor, "Nathan Levinson")
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCharacters() {
        let path = "//spotting-notes/title[1]/character"
        
        do {
            guard let result = try document?.rootElement()?.nodes(forXPath: path) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(result.count, 13)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testPerformanceStructuredOutput() {
        
        let engine = XMLConversionEngine()
        engine.stylesheet = .structured
        
        var outputData : Data? = nil
        
        self.measure {
            outputData = try! engine.convert(fileURL: RobinHoodTest.robinHoodURL)
        }
        
        print(outputData?.count ?? 0)
    }
    
    func testCharacterOrder() {
        let path = "//spotting-notes/title[1]/character/name"
        
        do {
            guard let result = try document?.rootElement()?.nodes(forXPath: path) else {
                XCTFail()
                return
            }
            
            let namesInDoc = result.map { $0.stringValue ?? "_" }
            
            let namesInOrder = ["Robin",
                                "Will",
                                "Marian",
                                "John",
                                "Guy",
                                "Much",
                                "Butcher",
                                "Town Crier",
                                "Soldier 1",
                                "Soldier 2",
                                "Soldier 3",
                                "Priest",
                                "Guest at Court"]
            
            
            XCTAssertEqual(namesInDoc, namesInOrder)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

}

//
//  LineIndentTests.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/25/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

class LineIndentTests: XCTestCase {

    func testLineIndent() {
        // spaces, width of 4
        do {
            let indent = LineIndent(useTabs: false, indentationWidth: 4)
            
            XCTAssertEqual(indent.level, 0, "level")
            XCTAssertEqual(indent.indentPerLevel, "    ", "indent per level spaces width of 4")
            
            XCTAssertEqual("\(indent)", "", "indent string convertible spaces width of 4")
        }
        
        // tabs, width of 8
        do {
            let indent = LineIndent(useTabs: true, indentationWidth: 8, level: 2)
            
            XCTAssertEqual(indent.level, 2, "level")
            XCTAssertEqual(indent.indentPerLevel, "\t", "indent per level tabs width of 8")
            
            XCTAssertEqual("\(indent)", "\t\t", "indent string convertible tabs width of 8")
        }
        
        // spaces, width of 2
        do {
            let indent = LineIndent(useTabs: false, indentationWidth: 2, level: 1)
            
            XCTAssertEqual(indent.level, 1, "level")
            XCTAssertEqual(indent.indentPerLevel, "  ", "indent per level spaces width of 2")
            
            XCTAssertEqual("\(indent)", "  ", "indent string convertible spaces width of 2")
        }
    }
    
    func testLineIndented() {
        let indent = LineIndent(useTabs: false, indentationWidth: 4)
        
        // spaces, width of 4
        do {
            let nextIndent = indent.indented()
 
            XCTAssertEqual(indent.level, 0, "default level should still be 0")
            
            
            XCTAssertEqual(nextIndent.level, 1, "next indent level should be 1")
            XCTAssertEqual(nextIndent.indentPerLevel, "    ", "next indent's indent per level spaces width of 4")

            XCTAssertEqual("\(nextIndent)", "    ", "next indent string convertible spaces width of 4")

            let nextNextIndent = nextIndent.indented()
            XCTAssertEqual(nextNextIndent.level, 2, "next next indent level")
            XCTAssertEqual(nextNextIndent.indentPerLevel, "    ", "next next indent's indent per level spaces width of 4")
            
            XCTAssertEqual("\(nextNextIndent)", "        ", "next next indent string convertible spaces width of 4")
        }
    }

}

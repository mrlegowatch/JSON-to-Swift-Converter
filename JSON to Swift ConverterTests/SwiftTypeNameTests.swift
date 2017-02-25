//
//  SwiftTypeNameTests.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/25/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

class SwiftTypeNameTests: XCTestCase {

    
    func testSwiftType() {
        do {
            XCTAssertEqual("".swiftType, "", "empty string should be empty")
        }

        do {
            XCTAssertEqual("ABBY".swiftType, "ABBY", "swift type already capitalized")
        }
        
        do {
            XCTAssertEqual("frodo".swiftType, "Frodo", "swift type not yet capitalized")
        }
        
        do {
            XCTAssertEqual("hello world".swiftType, "HelloWorld", "swift type multiple words")
        }
        
        do {
            XCTAssertEqual("big blue marble in space".swiftType, "BigBlueMarbleInSpace", "swift type multiple words")
        }
        
    }
    
    func testSwiftName() {
        do {
            XCTAssertEqual("".swiftName, "", "empty string should be empty")
        }
        
        do {
            XCTAssertEqual("ABBY".swiftName, "aBBY", "swift type already capitalized")
        }
        
        do {
            XCTAssertEqual("frodo".swiftName, "frodo", "swift type not yet capitalized")
        }
        
        do {
            XCTAssertEqual("hello world".swiftName, "helloWorld", "swift type multiple words")
        }
        
        do {
            XCTAssertEqual("big blue marble in space".swiftName, "bigBlueMarbleInSpace", "swift type multiple words")
        }
        
    }

}

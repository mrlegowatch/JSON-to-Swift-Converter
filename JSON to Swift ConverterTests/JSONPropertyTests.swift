//
//  JSONPropertyTests.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/25/17.
//  Copyright © 2018 Brian Arnold. All rights reserved.
//

import XCTest

class JSONPropertyTests: XCTestCase {

    var appSettings: AppSettings!
    
    override func setUp() {
        super.setUp()
        
        // Use an isolated version of app settings
        appSettings = AppSettings(UserDefaults(suiteName: "JSON-to-Swift-tests-properties")!)
        
        appSettings.reset()
    }
    
    func testNumberValueType() {
        do {
            let bool = NSNumber(value: true)
            let (type, defaultValue) = bool.valueType
            XCTAssertEqual(type, "Bool", "NSNumber Bool type")
            XCTAssertEqual(defaultValue, "false", "NSNumber Bool default value")
        }
        
        do {
            let int = NSNumber(value: 31)
            let (type, defaultValue) = int.valueType
            XCTAssertEqual(type, "Int", "NSNumber Int type")
            XCTAssertEqual(defaultValue, "0", "NSNumber Int default value")
        }
        
        do {
            let double = NSNumber(value: -78.234)
            let (type, defaultValue) = double.valueType
            XCTAssertEqual(type, "Double", "NSNumber Double type")
            XCTAssertEqual(defaultValue, "0.0", "NSNumber Double default value")
        }
    }
    
    func testStringTojsonObject() {
        // Empty string
        do {
            let string = ""
            let object = string.jsonObject
            XCTAssertNil(object, "empty string should produce nil")
        }
        
        // Simple string
        do {
            let string = "\"name\""
            let object = string.jsonObject
            XCTAssertNil(object, "simple string should produce nil dictionary")
        }
        
        // Simple dictionary
        do {
            let string = "{ \"name\": \"Frodo\" }"
            let dictionary = string.jsonObject as? [String: Any]
            XCTAssertNotNil(dictionary, "simple dictionary should be non-nil")
            
            XCTAssertEqual(dictionary?["name"] as? String, "Frodo", "simple dictionary should have an item")
        }
        
        // Negative test, badly constructed dictionary
        do {
            let string = "{ \"name\":  }"
            let dictionary = string.jsonObject
            XCTAssertNil(dictionary, "simple dictionary should be non-nil")
        }

        
    }
    
    func testSimpleProperty() {
        /// Test a simple property
        do {
            let property = JSONProperty("key", name: "name", dictionary: [:], appSettings: appSettings)
            XCTAssertEqual(property.key, "key", "property key")
            XCTAssertEqual(property.name, "name", "property name")
            XCTAssertTrue(property.dictionary.isEmpty, "property dictionary")
        }
        
        /// Test an invalid string
        do {
            let property = JSONProperty(from: "\"hello\"", appSettings: appSettings)
            XCTAssertNil(property, "simple string should return nil property")
        }
    }
    
    func testDictionaryProperty() {
        /// Test a slightly non-trival dictionary with child dictionaries, arrays of ints, and arrays of dictionaries
        let string = "{ \"name\": \"Bilbo\", \"info\": [ { \"age\": 111 }, { \"weight\": 25.8 } ], \"attributes\": { \"strength\": 12 }, \"miscellaneous scores\": [2, 3] }"
        
        let property = JSONProperty(from: string, appSettings: appSettings)
        XCTAssertNotNil(property, "property should be non-nil")
        
        let indent = LineIndent(useTabs: false, indentationWidth: 4)
        
        // Note: we are going to mess with app settings shared instance, which affects state across unit test sessions.

        do {
            // NB, this is a white box test, allKeys shouldn't be called directly
            let keys = property!.allKeys
            print("keys = \(keys)")
            
            // TODO: see comment in JSONProperty regarding [Any] children
            // the parsing via makeRootProperty misses the second array dictionary "weight" key
            XCTAssertEqual(keys.count, 6 /*7*/, "property should have 7 unique keys")
            
            // Test propertyKeys output
            let propertyKeys = property?.propertyKeys(indent: indent)
            print("propertyKeys = \n\(propertyKeys ?? "")")
            
            XCTAssertTrue(propertyKeys?.hasPrefix("\nprivate enum CodingKeys: String, CodingKey {\n") ?? false, "prefix for property keys")
            XCTAssertTrue(propertyKeys?.contains("    case ") ?? false, "declarations for property keys")
            XCTAssertTrue(propertyKeys?.contains(" miscellaneousScores = ") ?? false, "a specific key declaration")
            XCTAssertTrue(propertyKeys?.contains("\"miscellaneous scores\"") ?? false, "a specific key value")
            XCTAssertTrue(propertyKeys?.hasSuffix("\n}\n") ?? false, "suffix for property keys")
        }
        
        // Test typeContent output
        do {
            let typeContent = property?.typeContent(indent: indent)
            XCTAssertFalse(typeContent?.isEmpty ?? true, "typeContent should be non-empty")
            print("typeContent = \n\(typeContent ?? "")")

            XCTAssertTrue(typeContent?.contains("struct <#InfoType#>: Codable {") ?? false, "a specific type declaration")
            XCTAssertTrue(typeContent?.contains("struct <#AttributesType#>: Codable {") ?? false, "a specific type declaration")
        }
        
        // Test propertyContent output
        do {
            let propertyContent = property?.propertyContent(indent: indent)
            XCTAssertFalse(propertyContent?.isEmpty ?? true, "typeContent should be non-empty")
            print("propertyContent (default) = \n\(propertyContent ?? "")")
            
            XCTAssertTrue(propertyContent?.contains("let info: [<#InfoType#>]!") ?? false, "a specific type declaration")
            XCTAssertTrue(propertyContent?.contains("let name: String!") ?? false, "a specific type declaration")
            XCTAssertTrue(propertyContent?.contains("let attributes: <#AttributesType#>!") ?? false, "a specific type declaration")
            XCTAssertTrue(propertyContent?.contains("let miscellaneousScores: [Int]!") ?? false, "a specific type declaration")
        }
        
        do {
            // Change the defaults and check the new output
            appSettings.declaration = .useVar
            appSettings.typeUnwrapping = .optional
            appSettings.addDefaultValue = true
            
            let propertyContent = property?.propertyContent(indent: indent)
            print("propertyContent (non-default) = \n\(propertyContent ?? "")")

            XCTAssertTrue(propertyContent?.contains("var info: [<#InfoType#>]? = []") ?? false, "a specific type declaration")
            XCTAssertTrue(propertyContent?.contains("var name: String? = \"\"") ?? false, "a specific type declaration")
            XCTAssertTrue(propertyContent?.contains("var attributes: <#AttributesType#>? = [:]") ?? false, "a specific type declaration")
            XCTAssertTrue(propertyContent?.contains("var miscellaneousScores: [Int]? = []") ?? false, "a specific type declaration")
        }
        
    }

    func testAddInitAndDictionary() {
        let string = "{ \"name\": \"Bilbo\", \"info\": [ { \"age\": 111 }, { \"weight\": 25.8 } ], \"attributes\": { \"strength\": 12 }, \"miscellaneous scores\": [2, 3] }"

        let property = JSONProperty(from: string, appSettings: appSettings)
        XCTAssertNotNil(property, "property should be non-nil")
        
        let indent = LineIndent(useTabs: false, indentationWidth: 4)
        
        // Note: we are going to mess with app settings shared instance, which affects state across unit test sessions.
        appSettings.addDefaultValue = true
        appSettings.supportCodable = true
        
        // var with optional will set default values in the declarations
        do {
            appSettings.declaration = .useVar
            appSettings.typeUnwrapping = .optional
            
            let propertyContent = property?.propertyContent(indent: indent)
            print("init with var and optional = \n\(propertyContent ?? "")")
        }

        // let with optional will set default values in the init method
        do {
            appSettings.declaration = .useLet
            appSettings.typeUnwrapping = .optional
            
            let propertyContent = property?.propertyContent(indent: indent)
            print("init with let and optional = \n\(propertyContent ?? "")")
        }

        // let with explicit will use guard
        do {
            appSettings.declaration = .useLet
            appSettings.typeUnwrapping = .explicit
            
            let propertyContent = property?.propertyContent(indent: indent)
            print("init with let and explicit = \n\(propertyContent ?? "")")
        }

    }
    
    func testJSONArray() {
        let string = "[\"name\", \"age\"]"
        
        let property = JSONProperty(from: string, appSettings: appSettings)
        XCTAssertNotNil(property, "property should be non-nil")

        let indent = LineIndent(useTabs: false, indentationWidth: 4)

        do {
            let propertyContent = property?.propertyContent(indent: indent)
            print("propertyContent (array) = \n\(propertyContent ?? "")")
        }
    }
    
    func testJSONPropertyOutput() {
        guard let testClassesFile = Bundle(for: JSONPropertyTests.self).url(forResource: "TestClasses", withExtension: "json") else {
            XCTFail("TestClasses.json is missing")
            return
        }
        guard let testClasses = try? String(contentsOf: testClassesFile) else {
            XCTFail("TestClasses.json could not be converted to string.")
            return
        }
        guard let property = JSONProperty(from: testClasses, appSettings: appSettings) else {
            XCTFail("JSONProperty could not be parsed.")
            return
        }
        
        let lineIndent = LineIndent(useTabs: false, indentationWidth: 4, level: 1)
        
        let propertyKeys = property.propertyKeys(indent: lineIndent)
        print("propertyKeys = \n\(propertyKeys)")
        
        let typeContent = property.typeContent(indent: lineIndent)
        print("typeContent = \n\(typeContent)")
        
        let propertyContent = property.propertyContent(indent: lineIndent)
        print("propertyContent = \n\(propertyContent)")
    }
    
    func testJSONPropertyPerformance() {
        let testClassesFile = Bundle(for: JSONPropertyTests.self).url(forResource: "TestClasses", withExtension: "json")!
        let testClasses = try! String(contentsOf: testClassesFile, encoding: .utf8)
        let property = JSONProperty(from: testClasses, appSettings: appSettings)!

        self.measure {
        
            let lineIndent = LineIndent(useTabs: false, indentationWidth: 4, level: 1)
            
            let _ = property.propertyKeys(indent: lineIndent)
            let _ = property.typeContent(indent: lineIndent)
            let _ = property.propertyContent(indent: lineIndent)
        }
    }

}

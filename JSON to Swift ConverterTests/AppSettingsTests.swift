//
//  AppSettingsTests.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/25/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest


class AppSettingsTests: XCTestCase {
    
    func testSharedInstance() {
        /// Only use AppSettings.sharedInstance once here for code coverage,
        /// because it will access the shared UserDefaults which may change between tests.
        let _ = AppSettings.sharedInstance
    }
    
    func testDefaultSettings() {
        let appSettings = AppSettings(UserDefaults(suiteName: "JSON-to-Swift-tests-defaults")!)
        
        XCTAssertEqual(appSettings.declaration, .useLet, "default for declaration")
        XCTAssertEqual(appSettings.typeUnwrapping, .required, "default for type unwrapping")
        XCTAssertTrue(appSettings.addKeys, "default for add keys")
        XCTAssertFalse(appSettings.addDefaultValue, "default for add default value")
        XCTAssertFalse(appSettings.addInitAndDictionary, "default for add init and dictionary")
    }

    func testChangingSettings() {
        var appSettings = AppSettings(UserDefaults(suiteName: "JSON-to-Swift-tests-changing")!)

        appSettings.declaration = .useVar
        XCTAssertEqual(appSettings.declaration, .useVar, "declaration")
        
        appSettings.typeUnwrapping = .explicit
        XCTAssertEqual(appSettings.typeUnwrapping, .explicit, "type unwrapping")

        appSettings.typeUnwrapping = .optional
        XCTAssertEqual(appSettings.typeUnwrapping, .optional, "type unwrapping")

        appSettings.addKeys = false
        XCTAssertFalse(appSettings.addKeys, "add keys")
        
        appSettings.addDefaultValue = true
        XCTAssertTrue(appSettings.addDefaultValue, "add default value")
        
        appSettings.addInitAndDictionary = true
        XCTAssertTrue(appSettings.addInitAndDictionary, "add init and dictionary")
    }
    
    func testTypeUnwrappingStringConvertible() {
        XCTAssertEqual("\(AppSettings.TypeUnwrapping.explicit)", "", "type unwrapping explicit string")
        XCTAssertEqual("\(AppSettings.TypeUnwrapping.optional)", "?", "type unwrapping optional string")
        XCTAssertEqual("\(AppSettings.TypeUnwrapping.required)", "!", "type unwrapping required string")
    }
    
}

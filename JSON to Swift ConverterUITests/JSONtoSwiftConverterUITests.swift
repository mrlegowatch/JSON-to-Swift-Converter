//
//  JSONtoSwiftConverterUITests.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/20/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

class JSONtoSwiftConverterUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSettings() {
        let window = XCUIApplication().windows["JSON to Swift Converter Settings"]
        let letRadioButton = window.radioButtons["let"]
        let varRadioButton = window.radioButtons["var"]
        
        let explicitRadioButton = window.radioButtons["Explicit"]
        let optionalRadioButton = window.radioButtons["? Optional"]
        let requiredRadioButton = window.radioButtons["! Required"]
        
        let supportCodableCheckBox = window.checkBoxes["Support Codable"]
        let addDefaultValuesCheckBox = window.checkBoxes["Add default values"]
        
        let outputStaticText = window.staticTexts["outputStaticText"]

        // TODO: "reset" the target application's UserDefaults default suite settings in 
        // a way that actually works. The trick used in the logic unit tests doesn't work 
        // here. Is it because we are out-of-process, don't have entitlements for the suite, 
        // or something else? In the meantime, we instead reset the initial state of the controls.
        
        // Reset the initial state of the controls
        letRadioButton.click()
        requiredRadioButton.click()
        if let value = supportCodableCheckBox.value as? Int, value != 1 {
            supportCodableCheckBox.click()
        }
        if let value = addDefaultValuesCheckBox.value as? Int, value != 0 {
            addDefaultValuesCheckBox.click()
        }
        
        // Validate the initial state of the controls
        XCTAssertEqual(letRadioButton.value as? Int, 1, "let should be selected")
        XCTAssertEqual(varRadioButton.value as? Int, 0, "var should not be selected")
        
        XCTAssertEqual(explicitRadioButton.value as? Int, 0, "explicit should not be selected")
        XCTAssertEqual(optionalRadioButton.value as? Int, 0, "optional should not be selected")
        XCTAssertEqual(requiredRadioButton.value as? Int, 1, "required should be selected")
        
        XCTAssertEqual(supportCodableCheckBox.value as? Int, 1, "add key should be selected")
        XCTAssertEqual(addDefaultValuesCheckBox.value as? Int, 0, "add default values should be deselected")
        
        // Confirm the initial state of the output static text
        do {
            let output = outputStaticText.value as? String
            let lines = output?.components(separatedBy: "\n")
            XCTAssertEqual(lines?.count, 10, "number of lines of output")
        }

        varRadioButton.click()
        XCTAssertEqual(letRadioButton.value as? Int, 0, "let should not be selected")
        XCTAssertEqual(varRadioButton.value as? Int, 1, "var should be selected")
        
        optionalRadioButton.click()
        XCTAssertEqual(explicitRadioButton.value as? Int, 0, "explicit should not be selected")
        XCTAssertEqual(optionalRadioButton.value as? Int, 1, "optional should be selected")
        XCTAssertEqual(requiredRadioButton.value as? Int, 0, "required should not be selected")
        
        explicitRadioButton.click()
        XCTAssertEqual(explicitRadioButton.value as? Int, 1, "explicit should be selected")
        XCTAssertEqual(optionalRadioButton.value as? Int, 0, "optional should not be selected")
        XCTAssertEqual(requiredRadioButton.value as? Int, 0, "required should not be selected")
        
        supportCodableCheckBox.click()
        XCTAssertEqual(supportCodableCheckBox.value as? Int, 0, "add key should not be selected")
        do {
            let output = outputStaticText.value as? String
            let lines = output?.components(separatedBy: "\n")
            XCTAssertEqual(lines?.count, 4, "number of lines of output")
        }
        
        addDefaultValuesCheckBox.click()
        XCTAssertEqual(addDefaultValuesCheckBox.value as? Int, 1, "add default values should be selected")

        // Turn add key back on so we can test add init and add var dictionary
        supportCodableCheckBox.click()
        
        do {
            let output = outputStaticText.value as? String
            let lines = output?.components(separatedBy: "\n")
            XCTAssertEqual(lines?.count, 10, "number of lines of output")
        }
    }
    
}

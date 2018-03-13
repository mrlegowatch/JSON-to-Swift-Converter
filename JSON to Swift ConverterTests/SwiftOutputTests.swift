//
//  SwiftOutputTests.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 3/4/18.
//  Copyright © 2018 Brian Arnold. All rights reserved.
//

import XCTest

struct SwiftSourceFile {
    
    let url: URL
    
    init(_ path: String) {
        self.url = URL(fileURLWithPath: path)
    }
    
    func write(_ string: String) throws {
        try string.write(to: url, atomically: true, encoding: .utf8)
    }
    
    func compile() -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/swiftc"
        process.arguments = ["-emit-executable", url.path]
        process.launch()
        process.waitUntilExit()
        
        // TODO: extract stdout, stderr
        return process.terminationStatus == 0
    }
}

extension AppSettings {
    
    static let allDeclarations: [Declaration] = [.useLet, .useVar]
    static let allSupportCodables: [Bool] = [false, true]
    static let allTypeUnwrapping: [TypeUnwrapping] = [.explicit, .optional, .required]
    static let allAddDefaultValue: [Bool] = [false, true]
    
    // TODO: I couldn't think of a better way to aggregate all combinations
    // of settings for testing.
    mutating func visit(_ block: (_ description: String, _ filePath: String) -> ()) {
        for declaration in AppSettings.allDeclarations {
            self.declaration = declaration
            for supportCodable in AppSettings.allSupportCodables {
                self.supportCodable = supportCodable
                for typeUnwrapping in AppSettings.allTypeUnwrapping {
                    self.typeUnwrapping = typeUnwrapping
                    
                    for addDefaultValue in AppSettings.allAddDefaultValue {
                        self.addDefaultValue = addDefaultValue
                        block("\(self)", filePath)
                    }
                }
            }
        }
    }
}

extension AppSettings: CustomStringConvertible {
    
    public var description: String {
        return "declaration=\(declaration) typeUnwrapping=\(typeUnwrapping) addDefaultValue=\(addDefaultValue) supportCodable=\(supportCodable)"
    }
}

extension AppSettings {
    
    static func temporaryFile(_ name: String) -> String {
        let temporaryDirectory = FileManager.default.temporaryDirectory.path
        return "\(temporaryDirectory)/\(name).swift"
    }
    
    public var fileName: String {
        return "SwiftOutput_\(declaration)_unwrapping_\(typeUnwrapping)_default_\(addDefaultValue)_codable_\(supportCodable)"
    }
    
    public var filePath: String {
        return AppSettings.temporaryFile(fileName)
    }
}

class SwiftOutputTests: XCTestCase {

    var appSettings: AppSettings!

    override func setUp() {
        super.setUp()
        
        // This test is sensitive to UserDefaults state which persists between unit test sessions.
        // Use an isolated version of app settings
        appSettings = AppSettings(UserDefaults(suiteName: "JSON-to-Swift-tests-swiftOutput")!)

        appSettings.reset()
    }

    func testSwiftOutput() {
        // For each combination of AppSettings, produce output in log files that can be inspected by a human.
        guard let url = Bundle(for: SwiftOutputTests.self).url(forResource: "TestClasses", withExtension: "json") else {
            XCTFail("TestClasses.json is not in the test bundle.")
            return
        }
        guard let jsonString = try? String(contentsOf: url) else {
            XCTFail("TestClasses.json could not be converted to string.")
            return
        }
        guard let jsonProperty = JSONProperty(from: jsonString, appSettings: appSettings) else {
            XCTFail("JSONProperty could not be parsed.")
            return
        }
  
        let indent = LineIndent(useTabs: false, indentationWidth: 4, level: 1)

        // AppSettings has 2x3x2x2 or 24 combinations.
        appSettings.visit { (description: String, filePath: String) in
            var swiftOutput = jsonProperty.generateOutput(lineIndent: indent)
            
            // Replace the placeholder so it's easier to check for syntax.
            swiftOutput = swiftOutput.replacingOccurrences(of: "<#ClassesType#>", with: "Classes")

            let swiftFile = SwiftSourceFile(filePath)
            var code = "// AppSettings:\n"
            code += "// \(description)\n"
            code += "struct TestType {\n"
            code += swiftOutput
            code += "\n}\n"
            do {
                try swiftFile.write(code)
            } catch {
                XCTFail("Failed to write \(filePath), error=\(error)")
            }
            
            // TODO: can't compile directly, because the executable is sandboxed.
            //XCTAssertTrue(swiftFile.compile(), "Failed to compile \(filePath)")
        }
        
        // Workaround: check the generated source files by hand, by opening them
        // and pasting their contents into a Swift Playground.
        print()
        print("Generated temporary Swift source files.")
        print("To inspect their contents, invoke:")
        print("open \(FileManager.default.temporaryDirectory.path)/*.swift")
        print()
    }
}


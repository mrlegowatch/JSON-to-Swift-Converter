//
//  SourceEditorCommand.swift
//  Convert JSON to Swift
//
//  Created by Brian Arnold on 2/20/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation
import XcodeKit
import Cocoa // For NSWorkspace

struct ConversionError {
    
    // This extension uses NSError instead of Error, so that the user sees a 
    // readable message in Xcode when there is a problem.
    
    static let domain = "com.flatearthstudio.Convert-JSON-to-Swift"
    
    static func localized(_ message: String) ->  [String : Any] {
        // TODO: localize the error messages
        return [NSLocalizedDescriptionKey: message]
    }
    
    static let noSelection = NSError(domain: domain, code: -1, userInfo: localized("Could not convert: no selected text"))
    
    static let invalidJSON = NSError(domain: domain, code: -1, userInfo: localized("Could not convert: invalid JSON format"))
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    /// Command identifier for the Convert menu item
    let convert = "com.flatearthstudio.convert-json-to-swift.convert"
    
    /// Command identifier for the Settings menu item
    let settings = "com.flatearthstudio.convert-json-to-swift.settings"
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        switch invocation.commandIdentifier {
        case convert:
            do {
                try convertJSONToSwift(invocation.buffer)
            }
            catch let error {
                completionHandler(error)
            }
        case settings:
            openSettingsApp()
        default:
            break
        }
        
        completionHandler(nil)
    }
    
    func convertJSONToSwift(_ buffer: XCSourceTextBuffer) throws {
        let range = buffer.selections.firstObject as! XCSourceTextRange
        
        var jsonString = ""
        for index in range.start.line..<range.end.line {
            jsonString += buffer.lines[index] as! String
        }
        guard !jsonString.isEmpty else { throw ConversionError.noSelection }
        guard let property = JSONProperty(from: jsonString) else { throw ConversionError.invalidJSON }
        
        outputResult(property, to: buffer, in: range)
    }
    
    func openSettingsApp() {
        NSWorkspace.shared.launchApplication(withBundleIdentifier: "com.flatearthstudio.JSON-to-Swift-Converter", options: [], additionalEventParamDescriptor: nil, launchIdentifier: nil)
    }
    
    func outputResult(_ property: JSONProperty, to buffer: XCSourceTextBuffer, in range: XCSourceTextRange) {
        // Remove the current lines
        buffer.lines.removeObjects(in: NSRange(location: range.start.line, length: range.end.line - range.start.line))
        
        // Insert the new lines
        let lineIndent = LineIndent(useTabs: buffer.usesTabsForIndentation, indentationWidth: buffer.indentationWidth, level: 1)
        
        // Declare the keys
        let lineCount = buffer.lines.count
        buffer.lines.insert(property.propertyKeys(indent: lineIndent), at: range.start.line)
        var insertedLineCount = buffer.lines.count - lineCount

        // Declare the types
        buffer.lines.insert(property.typeContent(indent: lineIndent), at: range.start.line + insertedLineCount)
        insertedLineCount = buffer.lines.count - lineCount

        // Declare the properties
        buffer.lines.insert(property.propertyContent(indent: lineIndent), at: range.start.line + insertedLineCount)
        insertedLineCount = buffer.lines.count - lineCount
        
        // Update the selection
        let selection = XCSourceTextRange(start: XCSourceTextPosition(line: range.start.line, column: 0), end: XCSourceTextPosition(line: range.start.line + insertedLineCount, column: 0))
        buffer.selections.removeAllObjects()
        buffer.selections.insert(selection, at: 0)
    }
    
}

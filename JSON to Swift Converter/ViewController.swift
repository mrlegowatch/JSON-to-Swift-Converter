//
//  ViewController.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/20/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Cocoa

extension NSButton {
    
    var isChecked: Bool {
        return self.state == NSOnState
    }
    
}

extension String {
    
    /// Returns an attributed string with the specified color.
    func attributed(with color: NSColor) -> NSAttributedString {
        let attributes: [String: Any] = [NSForegroundColorAttributeName: color]
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
    
    /// Returns an attributed string with the Swift "keyword" color.
    var attributedKeywordColor: NSAttributedString {
        return self.attributed(with: NSColor(calibratedRed: 0.72, green: 0.2, blue: 0.66, alpha: 1.0))
    }
    
    /// Returns an attributed string with the Swift "type" color.
    var attributedTypeColor: NSAttributedString {
        return self.attributed(with: NSColor(calibratedRed: 0.44, green: 0.26, blue: 0.66, alpha: 1.0))
    }
    
    /// Returns an attributed string with the Swift "string literal" color.
    var attributedStringColor: NSAttributedString {
        return self.attributed(with: NSColor(calibratedRed: 0.84, green: 0.19, blue: 0.14, alpha: 1.0))
    }
    
    /// Returns an attributed string with the Swift "int literal" color.
    var attributedIntColor: NSAttributedString {
        return self.attributed(with: NSColor(calibratedRed: 0.16, green: 0.20, blue: 0.83, alpha: 1.0))
    }
    
    /// Returns self as an attributed string, for contatenation with other attributed strings.
    var attributed: NSAttributedString {
        return NSAttributedString(string: self)
    }
}

class ViewController: NSViewController {

    @IBOutlet weak var declarationLet: NSButton!
    @IBOutlet weak var declarationVar: NSButton!
    
    @IBOutlet weak var typeExplicit: NSButton!
    @IBOutlet weak var typeOptional: NSButton!
    @IBOutlet weak var typeRequired: NSButton!
    
    @IBOutlet weak var addDefaultValue: NSButton!
    @IBOutlet weak var addInitAndDictionary: NSButton!
    @IBOutlet weak var addKeys: NSButton!
    
    @IBOutlet weak var version: NSTextField! {
        didSet {
            version.stringValue = "Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)"
        }
    }

    @IBOutlet weak var output: NSTextField!
    
    var appSettings = AppSettings.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateControls()
        updateOutput()
    }

    /// Update the controls to match the user defaults settings
    func updateControls() {
        let isDeclarationLet = appSettings.declaration == .useLet
        declarationLet.state = isDeclarationLet ? NSOnState : NSOffState
        declarationVar.state = isDeclarationLet ? NSOffState : NSOnState
        
        let typeUnwrapping = appSettings.typeUnwrapping
        typeExplicit.state = typeUnwrapping == .explicit ? NSOnState : NSOffState
        typeOptional.state = typeUnwrapping == .optional ? NSOnState : NSOffState
        typeRequired.state = typeUnwrapping == .required ? NSOnState : NSOffState
        
        addDefaultValue.state = appSettings.addDefaultValue ? NSOnState : NSOffState
        addInitAndDictionary.state = appSettings.addInitAndDictionary ? NSOnState : NSOffState
        addKeys.state = appSettings.addKeys ? NSOnState : NSOffState
    }
    
    /// Update the output text view to reflect the current settings
    func updateOutput() {
        
        let declaration = appSettings.declaration == .useLet ? "let" : "var"
        let typeUnwrapping = appSettings.typeUnwrapping == .optional ? "?" : appSettings.typeUnwrapping == .required ? "!" : ""
        
        let outputData = [["user name", "String", "\"\""], ["age", "Int", "0"]]
        let outputString = NSMutableAttributedString(string: "")
        outputString.beginEditing()
        let lineIndent = LineIndent(useTabsForIndentation: false, indentationWidth: 4, level: 1)
        
        // Add the keys if set, scoped if set
        if appSettings.addKeys {
            outputString.append("struct".attributedKeywordColor)
            outputString.append(" Key {\n".attributed)
            for item in outputData {
                outputString.append("\(lineIndent)".attributed)
                outputString.append("let".attributedKeywordColor)
                outputString.append(" \(item[0].swiftName) = ".attributed)
                outputString.append("\"\(item[0])\"".attributedStringColor)
                outputString.append("\n".attributed)
            }
            outputString.append("}\n\n".attributed)
        }
        
        // Add the declarations
        for item in outputData {
            outputString.append("\(declaration)".attributedKeywordColor)
            outputString.append(" \(item[0].swiftName): ".attributed)
            outputString.append(": \(item[1])".attributedTypeColor)
            outputString.append("\(typeUnwrapping)".attributed)
            if appSettings.addDefaultValue {
                
                outputString.append(" = ".attributed)
                let value = item[2] == "0" ? "\(item[2])".attributedIntColor : "\(item[2])".attributedStringColor
                outputString.append(value)
            }
            outputString.append("\n".attributed)
        }
        
        // Add the init method and dictionary variable.
        if appSettings.addInitAndDictionary {
            outputString.append("\n".attributed)
            outputString.append("init".attributedKeywordColor)
            outputString.append("?(from dictionary: ".attributed)
            outputString.append("Any".attributedKeywordColor)
            outputString.append("?) { ... }\n".attributed)
            outputString.append("var".attributedKeywordColor)
            outputString.append(" dictionary: ".attributed)
            outputString.append("Any".attributedKeywordColor)
            outputString.append("? { ".attributed)
            outputString.append("return".attributedKeywordColor)
            outputString.append(" ... }".attributed)
        }
        
        outputString.endEditing()
        output.attributedStringValue = outputString
    }

    @IBAction func changeDeclaration(_ sender: NSButton) {
        let selectedTag = sender.selectedTag()
        appSettings.declaration = AppSettings.Declaration(rawValue: selectedTag)!
        updateOutput()
    }
    
    @IBAction func changeTypeUnwrapping(_ sender: NSButton) {
        let selectedTag = sender.selectedTag()
        appSettings.typeUnwrapping = AppSettings.TypeUnwrapping(rawValue: selectedTag)!
        updateOutput()
    }
    
    @IBAction func changeDefaultValue(_ sender: NSButton) {
        appSettings.addDefaultValue = sender.isChecked
        updateOutput()
    }

    @IBAction func changeAddKeys(_ sender: NSButton) {
        appSettings.addKeys = sender.isChecked
        updateOutput()
    }

    @IBAction func changeAddInitAndDictionary(_ sender: NSButton) {
        appSettings.addInitAndDictionary = sender.isChecked
        updateOutput()
    }
    
}

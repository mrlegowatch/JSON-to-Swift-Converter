//
//  ViewController.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/20/17.
//  Copyright © 2018 Brian Arnold. All rights reserved.
//

import Cocoa

extension NSButton {
    
    var isChecked: Bool {
        return self.state == .on
    }
    
}

extension String {
    
    /// Returns an attributed string with the specified color.
    func attributed(with color: NSColor) -> NSAttributedString {
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: color]
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
    @IBOutlet weak var supportCodable: NSButton!
    
    @IBOutlet weak var version: NSTextField! {
        didSet {
            version.stringValue = "Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)"
        }
    }

    @IBOutlet weak var output: NSTextField!
    
    var appSettings = AppSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateControls()
        updateOutput()
    }

    /// Update the controls to match the user defaults settings
    func updateControls() {
        let isDeclarationLet = appSettings.declaration == .useLet
        declarationLet.state = isDeclarationLet ? .on : .off
        declarationVar.state = isDeclarationLet ? .off : .on
        
        let typeUnwrapping = appSettings.typeUnwrapping
        typeExplicit.state = typeUnwrapping == .explicit ? .on : .off
        typeOptional.state = typeUnwrapping == .optional ? .on : .off
        typeRequired.state = typeUnwrapping == .required ? .on : .off
        
        addDefaultValue.state = appSettings.addDefaultValue ? .on : .off
        supportCodable.state = appSettings.supportCodable ? .on : .off
    }
    
    /// Update the output text view to reflect the current settings
    func updateOutput() {
        let declaration = appSettings.declaration == .useLet ? "let" : "var"
        let typeUnwrapping = appSettings.typeUnwrapping == .optional ? "?" : appSettings.typeUnwrapping == .required ? "!" : ""
        
        let outputData = [["user name", "String", "\"\""], ["age", "Int", "0"]]
        let outputString = NSMutableAttributedString(string: "")
        outputString.beginEditing()
        let lineIndent = LineIndent(useTabs: false, indentationWidth: 4, level: 1)
        
        // Add the coding keys (required for example because swiftName doesn't match JSON name)
        outputString.append("private enum".attributedKeywordColor)
        outputString.append(" CodingKeys: ".attributed)
        outputString.append("String".attributedKeywordColor)
        outputString.append(", ".attributed)
        outputString.append("CodingKey".attributedKeywordColor)
        outputString.append(" {\n".attributed)
        for item in outputData {
            outputString.append("\(lineIndent)".attributed)
            outputString.append("case ".attributedKeywordColor)
            outputString.append(" \(item[0].swiftName)".attributed)
            if item[0] != item[0].swiftName {
                outputString.append(" = ".attributed)
                outputString.append("\"\(item[0])\"".attributedStringColor)
            }
            outputString.append("\n".attributed)
        }
        outputString.append("}\n\n".attributed)

        
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
        
        outputString.append("\n".attributed)

        if appSettings.supportCodable {
            // Add the init method.
            do {//if appSettings.addInit {
                outputString.append("init".attributedKeywordColor)
                outputString.append("(from decoder: ".attributed)
                outputString.append("Decoder".attributedKeywordColor)
                outputString.append(") ".attributed)
                outputString.append("throws".attributedKeywordColor)
                outputString.append(" { ... }\n".attributed)
            }
     
            // Add the dictionary variable.
            do {//if appSettings.addDictionary {
                outputString.append("func encode".attributedKeywordColor)
                outputString.append("(to encoder: ".attributed)
                outputString.append("Encoder".attributedKeywordColor)
                outputString.append(") ".attributed)
                outputString.append("throws".attributedKeywordColor)
                outputString.append(" { ... }".attributed)
            }
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

    @IBAction func changeSupportCodable(_ sender: NSButton) {
        appSettings.supportCodable = sender.isChecked
        updateOutput()
    }
    
}

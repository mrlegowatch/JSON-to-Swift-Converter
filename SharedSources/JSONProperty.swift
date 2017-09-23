//
//  JSONProperty.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/20/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

extension NSNumber {
    
    // An NSNumber could be a Bool, Double or Int. Make a guess.
    // Returns the type as a string, and a safe default value as a string.
    internal var valueType: (type: String, defaultValue: String) {
        let typeStr: String
        let defaultValue: String
        
        if type(of: self) == type(of: NSNumber(value: true)) {
            // Testing against the type of NSNumber(value: true) gets at an internal boolean type
            typeStr = "Bool"
            defaultValue = "false"
        } else if "\(self)".contains(".") {
            // Assume a decimal point is present for JSON floating point numbers
            typeStr = "Double"
            defaultValue = "0.0"
        } else {
            typeStr = "Int"
            defaultValue = "0"
        }
        return (typeStr, defaultValue)
    }
    
}

extension String {
    
    /// Returns a JSON-parsed dictionary representation of this string.
    internal var jsonObject: Any? {
        let jsonData = self.data(using: .utf8)! // TODO: I could not find a way to break this, so using !
        return try? JSONSerialization.jsonObject(with: jsonData, options: [])
    }

}

/// This holds the name, key and dictionary pairs for a JSON property, and
/// and child dictionaries and arrays of contained properties.
public struct JSONProperty {
    
    internal var name: String
    internal var key: String
    internal var dictionary: [String: Any]
    
    internal var childDictionaries = [String: JSONProperty]()
    internal var childArrays = [String: JSONProperty]()
    
    /// Creates a property with a key, name and dictionary pair.
    internal init(_ key: String, name: String, dictionary: [String:Any]) {
        self.name = name
        self.key = key
        self.dictionary = dictionary
    }
       
    /// Creates a root property from the JSON-parsed root object.
    /// The root must be of type dictionary or array.
    public init?(from string: String) {
        guard let jsonObject = string.jsonObject else { return nil }
        
        let rootName = "rootName"
        let dictionary = jsonObject as? [String: Any] ?? ["<#rootName#>": jsonObject as! [Any]]
        
        self.init(rootName, name: rootName, dictionary: dictionary)
        
        self.makeChildProperties()
    }
    
    /// Identifies child dictionary and array properties and adds them as children.
    internal mutating func makeChildProperties() {
        let dictionary = self.dictionary
        for (key, value) in dictionary {
            if value is [Any] || value is [String: Any] {
                if let array = value as? [Any] {
                    if !(array.first is [Any] || array.first is [String: Any]) {
                        continue
                    }
                }
                
                let childTypeName = "<#\(key.swiftType)Type#>"
                if let dictionary = value as? [String: Any] {
                    var childProperty = JSONProperty(key, name: childTypeName, dictionary: dictionary)
                    childProperty.makeChildProperties()
                    self.childDictionaries[key] = childProperty
                } else if let array = value as? [Any] {
                    // TODO: this only captures the first item of the array, "gotta catch them all!"
                    if let dictionary = array.first as? [String: Any] {
                        var childProperty = JSONProperty(key, name: childTypeName, dictionary: dictionary)
                        childProperty.makeChildProperties()
                        self.childArrays[key] = childProperty
                    }
                }
            }
        }
    }

    /// Returns all of the keys of this property and all child properties.
    internal var allKeys: Set<String> {
        var keys = Set<String>()
        
        for (key, _) in self.dictionary {
            keys.insert(key)
        }
        
        for (_, value) in self.childDictionaries {
            keys.formUnion(value.allKeys)
        }
        
        for (_, value) in self.childArrays {
            keys.formUnion(value.allKeys)
        }
        
        return keys
    }
    
    /// Returns a Swift syntax string of all the keys of this property and all child 
    /// properties inside a struct. Returns an empty string if not adding key declarations.
    public func propertyKeys(indent: LineIndent) -> String {
        // Emit property keys anyway if swift name has to be different from string key.
        let keys = self.allKeys
        guard keys.first(where: { $0.swiftName != key }) != nil || AppSettings.sharedInstance.supportCodable else { return "" }

        var resultStr = "\n\(indent)private enum CodingKeys: String, CodingKey {\n"
        let keyIndent = indent.indented()
        for key in keys {
            resultStr.append("\(keyIndent)case \(key.swiftName)")
            if key.swiftName != key {
                resultStr.append(" = \"\(key)\"")
            }
            resultStr.append("\n")
        }
        resultStr.append("\(indent)}\n")
        
        return resultStr
    }
    
    /// Returns a Swift syntax string of all child type content.
    public func typeContent(indent: LineIndent) -> String {
        var result = ""
        
        for (_, value) in self.childDictionaries {
            result.append(String(format: "\n%@\n", value.childTypeContent(indent: indent)))
        }
        
        for (_, value) in self.childArrays {
            result.append(String(format: "\n%@\n", value.childTypeContent(indent: indent)))
        }
        result.append("\n")
        
        return result
        
    }
    
    /// Returns a Swift syntax string of each element of this property's dictionary.
    public func propertyContent(indent: LineIndent) -> String {
        var resultStr = ""
        
        for (key, value) in self.dictionary {
            resultStr.append(String(format: "\(indent)%@\n", format(key, value: value)))
        }
        resultStr.append(addInitContent(indent: indent));
        resultStr.append(addDictionaryContent(indent: indent));
        resultStr.append("\n")
        
        return resultStr
    }
    
    public func addInitContent(indent: LineIndent) -> String {
        let appSettings = AppSettings.sharedInstance
        // TODO: only generate an init method if the conditions are right (optional values, etc.)
        guard appSettings.supportCodable else { return "" }
        
        var resultStr = ""
        
        let childIndent = indent.indented()
        
        // TODO: use only one guard and only call else return nil once, not for every let
        // TODO: have an option to specify throws with an exception
        
        // Declare init(from dictionary: Any?) method
        resultStr.append("\(indent)\n\(indent)init(from decoder: Decoder) throws {\n")
        resultStr.append("\(childIndent)let container = try decoder.container(keyedBy: CodingKeys.self)\n\(childIndent)\n")

        for (key, value) in self.dictionary {
            resultStr.append(String(format: "\(childIndent)%@\n", initContent(key, value: value)))
        }

        // If the type unwrapping is not optional, initContent will have used guard and let,
        // so now the properties need to be set from the let values.
        let isTypeUnwrappingOptional = appSettings.typeUnwrapping == .optional
        if !isTypeUnwrappingOptional {
            resultStr.append("\(childIndent)\n")
            for (key, value) in self.dictionary {
                resultStr.append(String(format: "\(childIndent)%@\n", assignContent(key, value: value)))
            }
        }
        resultStr.append("\(indent)}\n\(indent)\n")
        
        return resultStr
    }
 
    public func addDictionaryContent(indent: LineIndent) -> String {
        let appSettings = AppSettings.sharedInstance
        // TODO: only generate an encode function if the conditions are right.
        guard appSettings.supportCodable else { return "" }
        
        var resultStr = ""
        
        let childIndent = indent.indented()
        
        // Declare dictionary: Any? var and getter
        resultStr.append("\(indent)func encode(to encoder: Encoder) throws {\n")
        resultStr.append("\(childIndent)var container = encoder.container(keyedBy: CodingKeys.self)\n\(childIndent)\n")
        for (key, value) in self.dictionary {
            resultStr.append(String(format: "\(childIndent)%@\n", dictionaryContent(key, value: value)))
        }
        resultStr.append("\(indent)}\n")
        
        return resultStr
    }

    /// Returns a Swift syntax string of this type followed by property content.
    internal func childTypeContent(indent: LineIndent) -> String {
        let childIndent = indent.indented()
        return "\(indent)struct \(self.name) {\n\(self.typeContent(indent: childIndent))\(self.propertyContent(indent: childIndent))\(indent)}"
    }
    
    internal func initContent(_ key: String, value: Any) -> String {
        let swiftKey = key.swiftName
        let (typeStr, _) = typeAndDefault(swiftKey, value)
        
        let appSettings = AppSettings.sharedInstance
        
        // If the type unwrapping is optional, use IfPresent to return optional value.
        let isTypeUnwrappingOptional = appSettings.typeUnwrapping == .optional
        let assignment = isTypeUnwrappingOptional ? "IfPresent" : ""
        return "let \(swiftKey) = try container.decode\(assignment)(\(typeStr).self, forKey: .\(swiftKey))"
    }
    
    internal func assignContent(_ key: String, value: Any) -> String {
        let swiftKey = key.swiftName
        return "self.\(swiftKey) = \(swiftKey)"
    }
    
    internal func dictionaryContent(_ key: String, value: Any) -> String {
        let swiftKey = key.swiftName
        
        let appSettings = AppSettings.sharedInstance

        let isTypeUnwrappingOptional = appSettings.typeUnwrapping == .optional
        let assignment = isTypeUnwrappingOptional ? "IfPresent" : ""

        return "try container.encode\(assignment)(\(swiftKey), forKey: .\(swiftKey))"
    }

    internal func typeAndDefault(_ swiftKey: String, _ value: Any) -> (String, String) {
        var typeStr = "String"
        var defaultValue = "\"\""
        
        switch value {
        case let number as NSNumber:
            (typeStr, defaultValue) = number.valueType
        case _ as String:
            typeStr = "String"
            defaultValue = "\"\""
        case let array as [Any]:
            let genericTypeStr: String
            let firstObject = array.first
            if firstObject is [String: Any], let childInfo = self.childArrays[swiftKey] {
                genericTypeStr = childInfo.name
            } else if firstObject is String {
                genericTypeStr = "String"
            } else if let number = firstObject as? NSNumber {
                (genericTypeStr, _) = number.valueType
            } else {
                genericTypeStr = "Any"
            }
            let childInfo = self.childArrays[key]
            typeStr = childInfo != nil ? "[\(childInfo!.name)]" : "[\(genericTypeStr)]"
            defaultValue = "[]"
        case _ as [String:Any]:
            let childInfo = self.childDictionaries[swiftKey]
            // TODO: Not testing for nil case, is childInfo always non-nil?
            typeStr = childInfo?.name ?? "<#\(key.swiftType)Type#>"
            defaultValue = "[:]"
        default:
            break
        }
        
        return (typeStr, defaultValue)
    }
    
    /// Returns a Swift syntax string of this property as a declaration with type and optional default value.
    internal func format(_ key: String, value: Any) -> String {
        let swiftKey = key.swiftName
        let (typeStr, defaultValue) = typeAndDefault(swiftKey, value)
        
        let appSettings = AppSettings.sharedInstance
        let declaration = appSettings.declaration == .useLet ? "let" : "var"
        let typeUnwrapping = "\(appSettings.typeUnwrapping)"
        // TODO: check logic here
        let defaultAssignment = appSettings.addDefaultValue && !(appSettings.supportCodable && appSettings.declaration == .useLet) ? " = \(defaultValue)" : ""
        return "\(declaration) \(swiftKey): \(typeStr)\(typeUnwrapping)\(defaultAssignment)"
    }

}

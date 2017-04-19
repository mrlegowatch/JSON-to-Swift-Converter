//
//  AppSettings.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/22/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation


public struct AppSettings {
    
    /// Returns a shared instance of this app's (shared) user defaults settings.
    public static let sharedInstance = AppSettings()
    
    /// The default shared user defaults suite for the settings application and the Xcode app extension.
    internal static let sharedUserDefaults = UserDefaults(suiteName: "JSON-to-Swift-Converter")!
    
    /// The internal settings.
    internal let userDefaults: UserDefaults
    
    /// The internal keys for the internal settings.
    internal struct Key {
        static let declaration = "Declaration"
        static let typeUnwrapping = "TypeUnwrapping"
        static let addDefaultValue = "AddDefaultValue"
        static let addKeys = "AddKeys"
        static let addInit = "AddInit"
        static let addDictionary = "AddDictionary"
    }
    
    /// Initializes to user defaults settings. Defaults to the shared user defaults.
    public init(_ userDefaults: UserDefaults = AppSettings.sharedUserDefaults) {
        self.userDefaults = userDefaults
    }
    
    /// Support for declaring a property as let or var.
    public enum Declaration: Int {
        case useLet = 0
        case useVar = 1
    }
    
    /// Accesses whether a property should be declared as let or var. Default is `.useLet`
    public var declaration: Declaration {
        get {
            guard userDefaults.object(forKey: Key.declaration) != nil else { return .useLet }
            return Declaration(rawValue: userDefaults.integer(forKey: Key.declaration))!
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Key.declaration)
        }
    }
    
    /// Support for type unwrapping of a property.
    public enum TypeUnwrapping: Int {
        case explicit = 0
        case optional = 1
        case required = 2
    }
    
    /// Accesses whether a property type should be unwrapped (as ? optional or ! required) or not (explicit).
    /// Default is `.required`
    public var typeUnwrapping: TypeUnwrapping {
        get {
            guard userDefaults.object(forKey: Key.typeUnwrapping) != nil else { return .required }
            return TypeUnwrapping(rawValue: userDefaults.integer(forKey: Key.typeUnwrapping))!
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Key.typeUnwrapping)
        }
    }
    
    /// Accesses whether to add key declarations. Default is true.
    public var addKeys: Bool {
        get {
            guard userDefaults.object(forKey: Key.addKeys) != nil else { return true }
            return userDefaults.bool(forKey: Key.addKeys)
        }
        set {
            userDefaults.set(newValue, forKey: Key.addKeys)
        }
    }
    
     /// Accesses whether to add a default value for the property. Default is false.
    public var addDefaultValue: Bool {
        get {
            guard userDefaults.object(forKey: Key.addDefaultValue) != nil else { return false }
            return userDefaults.bool(forKey: Key.addDefaultValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.addDefaultValue)
        }
    }
    
    /// Accesses whether to add init(from: Any?).
    public var addInit: Bool {
        get {
            guard userDefaults.object(forKey: Key.addInit) != nil else { return false }
            return userDefaults.bool(forKey: Key.addInit)
        }
        set {
            userDefaults.set(newValue, forKey: Key.addInit)
        }
    }

    /// Accesses whether to add var dictionary: Any? { get }.
    public var addDictionary: Bool {
        get {
            guard userDefaults.object(forKey: Key.addDictionary) != nil else { return false }
            return userDefaults.bool(forKey: Key.addDictionary)
        }
        set {
            userDefaults.set(newValue, forKey: Key.addDictionary)
        }
    }

}

extension AppSettings.TypeUnwrapping: CustomStringConvertible {
    
    /// Return the string representation for this type unwrapping.
    /// Returns an empty string if explicit, "?" if optional, "!" if required.
    public var description: String {
        let type: String
        
        switch self {
        case .explicit: type = ""
        case .optional: type = "?"
        case .required: type = "!"
        }
        
        return type
    }
}

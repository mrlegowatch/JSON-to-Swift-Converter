//
//  AppSettings.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/22/17.
//  Copyright © 2018 Brian Arnold. All rights reserved.
//

import Foundation

/// Persistence adapter for UserDefaults mapped to the settings required by this app. This also wraps the user defaults shared between the settings application and the Xcode app extension.
public struct AppSettings {
    
    /// The default shared user defaults suite for the settings application and the Xcode app extension.
    public static let sharedUserDefaults = UserDefaults(suiteName: "JSON-to-Swift-Converter")!
    
    /// The internal settings.
    internal let userDefaults: UserDefaults
    
    /// The internal keys for the internal settings.
    internal struct Key {
        static let declaration = "Declaration"
        static let typeUnwrapping = "TypeUnwrapping"
        static let addDefaultValue = "AddDefaultValue"
        static let supportCodable = "SupportCodable"
    }
    
    /// Initializes to user defaults settings. Defaults to the shared user defaults.
    public init(_ userDefaults: UserDefaults = sharedUserDefaults) {
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
    
    /// Accesses whether to add key declarations. Default is true.
    public var supportCodable: Bool {
        get {
            guard userDefaults.object(forKey: Key.supportCodable) != nil else { return true }
            return userDefaults.bool(forKey: Key.supportCodable)
        }
        set {
            userDefaults.set(newValue, forKey: Key.supportCodable)
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

extension AppSettings {
    
    /// For testing: encapsulate what it takes to do a full reset on settings.
    internal func reset() {
        // Note: Setting to plain 'nil' doesn't work; that causes a 'nil URL?' to be the default (weird). Radar'd.
        // Note: using setNilForKey doesn't work if the setting has already been set to NSNumber.
        let nilNSNumber: NSNumber? = nil
        userDefaults.set(nilNSNumber, forKey: Key.declaration)
        userDefaults.set(nilNSNumber, forKey: Key.typeUnwrapping)
        
        userDefaults.set(nilNSNumber, forKey: Key.supportCodable)
        userDefaults.set(nilNSNumber, forKey: Key.addDefaultValue)
    }
}

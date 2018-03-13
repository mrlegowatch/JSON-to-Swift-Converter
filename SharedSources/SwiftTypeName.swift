//
//  SwiftTypeName.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/21/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

extension String {
    
    /// Used to determine whether to capitalize for a Swift type, or to use lowercase for a name.
    internal enum SwiftTypeName {
        case type
        case name
    }
    
    /// Characters that cause the next character to be capitalized.
    internal static let removableCharacters: [Character] = [" ", "_", "-"]
    
    /// Returns whether this causes the next character to be capitalized.
    internal func isRemovable(_ character: Character) -> Bool {
        return String.removableCharacters.contains(character)
    }
    
    /// Returns whether this string contains any removable characters.
    internal func containsRemovableCharacters() -> Bool {
        return (self.first(where: { isRemovable($0) }) != nil)
    }
    
    /// Returns a camelCase version of this string with spaces, dashes and underscores removed.
    /// Each space in the name denotes a new capitalized word.
    ///
    /// - Parameter typeName: Capitalizes the beginning of the string if `.type`, 
    ///                       otherwise starts lowercase if `.name`.
    internal func camelCase(_ typeName: SwiftTypeName) -> String {
        guard !self.isEmpty else { return self }
        var newString: String = ""
        if !isRemovable(self.first!) {
            let first = String(self.first!)
            newString.append(typeName == .type ? first.uppercased() : first.lowercased())
        }
        var capitalizeNext = false
        for character in self.dropFirst() {
            if capitalizeNext {
                let uppercaseCharacter = String(character).uppercased()
                newString.append(uppercaseCharacter)
                capitalizeNext = false
            } else if isRemovable(character) {
                capitalizeNext = true
            } else {
                newString.append(character)
            }
        }
        
        return newString
    }
    
    /// Returns this string in camelCase with lowercase character first and spaces removed.
    public var swiftName: String {
        return camelCase(.name)
    }
    
    /// Returns this string in camelCase with uppercase character first and spaces removed.
    public var swiftType: String {
        return camelCase(.type)
    }
}

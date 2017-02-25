//
//  LineIndent.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 2/21/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// LineIndent captures the indentation settings for the current editor buffer and uses them
/// to generate the appropriate indentation for strings via CustomStringConvertible.
public struct LineIndent {
    
    /// The number of levels of indentation.
    internal let level: Int
    
    /// The number of spaces or a tab to indent per level.
    internal let indentPerLevel: String

    /// Creates a LineIndent from the settings for the current editor buffer.
    /// The default level of 0 has no indentation.
    public init(useTabsForIndentation: Bool, indentationWidth: Int, level: Int = 0) {
        self.level = level
        self.indentPerLevel = useTabsForIndentation ? "\t" : String(repeating: " ", count: indentationWidth)
    }
    
    /// Creates a new LineIndent from existing LineIndent values.
    internal init(_ level: Int, indentPerLevel: String) {
        self.level = level
        self.indentPerLevel = indentPerLevel
    }
    
    /// Returns a LineIndent with the indentation level incremented.
    public func indented() -> LineIndent {
        return LineIndent(self.level + 1, indentPerLevel: self.indentPerLevel)
    }
    
}

extension LineIndent: CustomStringConvertible {
    
    /// Returns a string formatted with the appropriate space or tab indentations 
    /// per level.
    public var description: String {
        return String(repeating: indentPerLevel, count: level)
    }
    
}

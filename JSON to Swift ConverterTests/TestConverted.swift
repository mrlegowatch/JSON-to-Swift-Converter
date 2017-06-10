//
//  TestConverted.swift
//  JSON to Swift Converter
//
//  Created by Brian Arnold on 4/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

class Foo {
    struct Key {
        
        static let info = "info"
        static let name = "name"
        static let attributes = "attributes"
        static let miscellaneousScores = "miscellaneous scores"
        static let strength = "strength"
        static let age = "age"
        
    }
    
    struct Attributes {
        
        let strength: Int!
        
    }
    
    struct Info {
        
        let age: Int!
        
    }

    var info: [Info]? = []
    var name: String? = ""
    var attributes: Attributes? = nil
    var miscellaneousScores: [Int]? = []
    
    init?(from dictionary: [String: Any]) {
        guard let info = dictionary[Key.info] as? [Info] else { return nil }
        guard let name = dictionary[Key.name] as? String else { return nil }
        guard let attributes = dictionary[Key.attributes] as? Attributes else { return nil }
        guard let miscellaneousScores = dictionary[Key.miscellaneousScores] as? [Int] else { return nil }
        
        self.info = info
        self.name = name
        self.attributes = attributes
        self.miscellaneousScores = miscellaneousScores
    }
    
    var dictionary: [String: Any] {
        var dictionary = [String: Any]()
        
        dictionary[Key.info] = info
        dictionary[Key.name] = name
        dictionary[Key.attributes] = attributes
        dictionary[Key.miscellaneousScores] = miscellaneousScores
        
        return dictionary
    }

}

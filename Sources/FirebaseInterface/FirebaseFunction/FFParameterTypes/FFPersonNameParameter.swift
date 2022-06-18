//
//  FFPersonNameParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Name of a person.
internal struct FFPersonNameParameter {
    
    /// First name of a person.
    public private(set) var first: String
    
    /// Last name of a person.
    public private(set) var last: String?
}

extension FFPersonNameParameter: FFParameterType {
    var parameter: [String: any FFParameterType] {
        return [
            "first": self.first,
            "last": self.last
        ]
    }
}

extension FFPersonNameParameter: Decodable {}

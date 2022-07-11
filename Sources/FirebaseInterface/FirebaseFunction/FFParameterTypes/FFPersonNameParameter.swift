//
//  FFPersonNameParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Name of a person.
public struct FFPersonNameParameter {
    
    /// First name of a person.
    public private(set) var first: String
    
    /// Last name of a person.
    public private(set) var last: String?
}

extension FFPersonNameParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        return [
            "first": self.first,
            "last": self.last
        ]
    }
}

extension FFPersonNameParameter: Decodable {}

extension FFPersonNameParameter: IPersonName {
    
    /// Initializes person name with a `IPersonName` protocol.
    /// - Parameter personName: `IPersonName` protocol to initialize the person name
    public init(_ personName: some IPersonName) {
        self.first = personName.first
        self.last = personName.last
    }
}

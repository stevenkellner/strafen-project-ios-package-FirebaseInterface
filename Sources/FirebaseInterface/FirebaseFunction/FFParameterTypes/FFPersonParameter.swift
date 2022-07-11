//
//  FFPersonParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Contains id and name of a person.
public struct FFPersonParameter {
    
    /// Id of the person.
    public private(set) var id: Person.ID
    
    /// Name of a person.
    public private(set) var name: FFPersonNameParameter
    
    public private(set) var signInData: FFSignInDataParameter?
}

extension FFPersonParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        return [
            "id": self.id,
            "name": self.name,
            "signInData": self.signInData
        ]
    }
}

extension FFPersonParameter: Decodable {}

extension FFPersonParameter: IPerson {
    
    /// Initializes person with a `IPerson` protocol.
    /// - Parameter person: `IPerson` protocol to initialize the person
    public init(_ person: some IPerson) {
        self.id = person.id
        self.name = FFPersonNameParameter(person.name)
        if let signInData = person.signInData {
            self.signInData = FFSignInDataParameter(signInData)
        }
    }
}

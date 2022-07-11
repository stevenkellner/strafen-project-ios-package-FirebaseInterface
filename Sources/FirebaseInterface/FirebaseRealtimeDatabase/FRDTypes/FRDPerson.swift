//
//  FRDPerson.swift
//  
//
//  Created by Steven on 17.06.22.
//

import StrafenProjectTypes

/// Contains id and name of a person in firebase realtime database.
public struct FRDPerson {
    
    /// Name of a person.
    public private(set) var name: FRDPersonName
    
    /// Sign in data of a person.
    public private(set) var signInData: FRDSignInData?
}

extension FRDPerson: Decodable {}

extension FRDPerson {
    
    /// Initializes person with a `IPerson` protocol.
    /// - Parameter person: `IPerson` protocol to initialize the person.
    public init(_ person: some IPerson) {
        self.name = FRDPersonName(person.name)
        if let signInData = person.signInData {
            self.signInData = FRDSignInData(signInData)
        }
    }
}

extension KeyValuePair: IPerson where Key == Person.ID, Value == FRDPerson {
    
    /// Initializes person with a `IPerson` protocol.
    /// - Parameter person: `IPerson` protocol to initialize the person.
    public init(_ person: some IPerson) {
        self.init(key: person.id, value: FRDPerson(person))
    }
    
    public var id: Person.ID {
        return self.key
    }
    
    public var name: FRDPersonName {
        return self.value.name
    }
    
    public var signInData: FRDSignInData? {
        return self.value.signInData
    }
}

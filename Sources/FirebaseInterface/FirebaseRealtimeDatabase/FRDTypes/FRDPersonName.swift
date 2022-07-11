//
//  FRDPersonName.swift
//  
//
//  Created by Steven on 17.06.22.
//

import StrafenProjectTypes

/// Name of a person in firebase realtime database.
public struct FRDPersonName {
    
    /// First name of a person.
    public private(set) var first: String
    
    /// Last name of a person.
    public private(set) var last: String?
}

extension FRDPersonName: Decodable {}

extension FRDPersonName: IPersonName {
    
    /// Initializes person name with a `IPersonName` protocol.
    /// - Parameter personName: `IPersonName` protocol to initialize the person name
    public init(_ personName: some IPersonName) {
        self.first = personName.first
        self.last = personName.last
    }
}

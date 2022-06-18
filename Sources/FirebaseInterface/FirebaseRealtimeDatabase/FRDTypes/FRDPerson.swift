//
//  FRDPerson.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation

/// Contains id and name of a person in firebase realtime database.
internal struct FRDPerson {
    
    /// Name of a person.
    public private(set) var name: FRDPersonName
}

extension FRDPerson: Decodable {}

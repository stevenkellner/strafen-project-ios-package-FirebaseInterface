//
//  FRDPersonName.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation

/// Name of a person in firebase realtime database.
internal struct FRDPersonName {
    
    /// First name of a person.
    public private(set) var first: String
    
    /// Last name of a person.
    public private(set) var last: String?
}

extension FRDPersonName: Decodable {}

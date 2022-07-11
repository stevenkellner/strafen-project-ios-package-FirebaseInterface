//
//  FFGetClubIdCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Get club id with given club identifier.
public struct FFGetClubIdCall: FFCallable {
    
    public typealias ReturnType = Club.ID
    
    public static let functionName: String = "getClubId"
    
    /// Identifier of the club to get id from.
    public private(set) var identifier: String
    
    public var parameters: FFParameters {
        FFParameter(self.identifier, for: "identifier")
    }
}

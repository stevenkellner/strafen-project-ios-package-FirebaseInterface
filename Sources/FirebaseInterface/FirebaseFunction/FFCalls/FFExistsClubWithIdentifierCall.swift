//
//  FFExistsClubWithIdentifierCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Checks if club with given identifier already exists.
public struct FFExistsClubWithIdentifierCall: FFCallable {

    public typealias ReturnType = Bool
    
    public static let functionName: String = "existsClubWithIdentifier"
    
    /// Identifier of the club to check existence.
    public private(set) var identifier: String
    
    public var parameters: FFParameters {
        FFParameter(self.identifier, for: "identifier")
    }
}

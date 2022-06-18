//
//  FFExistsClubWithIdentifierCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Checks if club with given identifier already exists.
internal struct FFExistsClubWithIdentifierCall: FFCallable {
    
    typealias ResultType = String
    
    static let functionName: String = "existsClubWithIdentifier"
    
    /// Identifier of the club to check existence.
    private let identifier: String
    
    var parameters: FFParameters {
        FFParameter(self.identifier, for: "identifier")
    }
}

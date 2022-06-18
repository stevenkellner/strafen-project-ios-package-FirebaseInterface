//
//  FFGetClubIdCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Get club id with given club identifier.
internal struct FFGetClubIdCall: FFCallable {
    
    typealias ResultType = String
    
    static let functionName: String = "getClubId"
    
    /// Identifier of the club to get id from.
    private let identifier: String
    
    var parameters: FFParameters {
        FFParameter(self.identifier, for: "identifier")
    }
}

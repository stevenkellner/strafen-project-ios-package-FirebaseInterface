//
//  FFGetPersonPropertiesCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Returns club and person properties of user id.
internal struct FFGetPersonPropertiesCall: FFCallable {
    
    struct ResultType: Decodable {
        
        /// Properties of person with specified user id.
        private let personProperties: FFPersonPropertiesWithIsAdminParameter
        
        /// Properties of club.
        private let clubProperties: FFClubPropertiesParameter
    }
    
    static let functionName: String = "getPersonProperties"
    
    /// User id of person to get properties from.
    private let userId: String
    
    var parameters: FFParameters {
        FFParameter(self.userId, for: "userId")
    }
}

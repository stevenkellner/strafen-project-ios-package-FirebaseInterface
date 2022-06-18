//
//  FFExistsPersonWithUserIdCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Checks if a person with given user id exists.
internal struct FFExistsPersonWithUserIdCall: FFCallable {
    
    typealias ResultType = String
    
    static let functionName: String = "existsPersonWithUserId"
    
    /// User id of person to check if exitsts.
    private let userId: String
    
    var parameters: FFParameters {
        FFParameter(self.userId, for: "userId")
    }
}

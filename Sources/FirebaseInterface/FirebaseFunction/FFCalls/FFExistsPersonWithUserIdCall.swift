//
//  FFExistsPersonWithUserIdCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Checks if a person with given user id exists.
public struct FFExistsPersonWithUserIdCall: FFCallable {
    
    public typealias ReturnType = Bool
    
    public static let functionName: String = "existsPersonWithUserId"
    
    /// User id of person to check if exitsts.
    public private(set) var userId: String
    
    public var parameters: FFParameters {
        FFParameter(self.userId, for: "userId")
    }
}

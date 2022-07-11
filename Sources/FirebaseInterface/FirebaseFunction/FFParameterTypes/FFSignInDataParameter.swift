//
//  FFSignInDataParameter.swift
//  
//
//  Created by Steven on 02.07.22.
//

import Foundation
import StrafenProjectTypes

public struct FFSignInDataParameter {
    
    /// Idicates whether person is admin.
    public private(set) var admin: Bool
    
    /// Date of sign in of the person.
    public private(set) var signInDate: Date
    
    /// User id of the person.
    public private(set) var userId: String
}

extension FFSignInDataParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        return [
            "admin": self.admin,
            "signInDate": self.signInDate,
            "userId": self.userId
        ]
    }
}

extension FFSignInDataParameter: Decodable {}

extension FFSignInDataParameter: ISignInData {
    
    /// Initializes sign in data with a `ISignInData` protocol.
    /// - Parameter signInData: `ISignInData` protocol to initialize the sign in data.
    public init(_ signInData: some ISignInData) {
        self.admin = signInData.admin
        self.signInDate = signInData.signInDate
        self.userId = signInData.userId
    }
}

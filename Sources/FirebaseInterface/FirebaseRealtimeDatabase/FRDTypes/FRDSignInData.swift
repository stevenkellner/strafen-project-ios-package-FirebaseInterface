//
//  FRDSignInData.swift
//  
//
//  Created by Steven on 01.07.22.
//

import Foundation
import StrafenProjectTypes

/// Sign in data of a person.
public struct FRDSignInData {
    
    /// Idicates whether person is admin.
    public private(set) var admin: Bool
    
    /// Date of sign in of the person.
    public private(set) var signInDate: Date
    
    /// User id of the person.
    public private(set) var userId: String
}

extension FRDSignInData: Decodable {}

extension FRDSignInData: ISignInData {
    
    /// Initializes sign in data with a `ISignInData` protocol.
    /// - Parameter signInData: `ISignInData` protocol to initialize the sign in data.
    public init(_ signInData: some ISignInData) {
        self.admin = signInData.admin
        self.signInDate = signInData.signInDate
        self.userId = signInData.userId
    }
}

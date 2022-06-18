//
//  FAuthenticator.swift
//  
//
//  Created by Steven on 17.06.22.
//

import FirebaseAuth

/// Handles firebase authentications.
internal struct FAuthenticator {
    
    /// Shared instance for singelton
    public static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Signs in a user with specified email and password.
    /// - Parameters:
    ///   - email: Email of the user to sign in.
    ///   - password: Password of the user to sign in.
    /// - Returns: Result of the sign in.
    @discardableResult
    public func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    /// Signs out current user.
    public func signOut() throws {
        try Auth.auth().signOut()
    }
}

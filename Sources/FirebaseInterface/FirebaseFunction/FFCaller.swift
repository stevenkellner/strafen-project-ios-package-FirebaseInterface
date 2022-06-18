//
//  FFCaller.swift
//  
//
//  Created by Steven on 12.06.22.
//

import FirebaseFunctions
import CodableFirebase

/// Used to call firebase functions.
internal struct FFCaller {
    
    /// Errors that can occur in a function call.
    enum CallError: Error {
        
        /// Private key isn't set for function call
        case noPrivateKey
    }
    
    /// Private key for firebase function.
    private var privateKey: String?
    
    /// Type of the database for firebase function calls.
    private var databaseType: DatabaseType = .default
    
    /// Shared instance for singelton
    public static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Creates the firebase function call parameters of specifed function call.
    /// Append private key and database type to parameters of specified function call.
    /// - Parameter functionCall: Function call to get other parameters from.
    /// - Returns: Firebase function call parameters of specifed function call.
    private func createParameters(
        of functionCall: some FFCallable
    ) throws -> [String: Any] {
        var parameters = functionCall.parameters
        guard let privateKey = self.privateKey else {
            throw CallError.noPrivateKey
        }
        parameters.append(privateKey, for: "privateKey")
        parameters.append(self.databaseType, for: "databaseType")
        return parameters.parameters.mapValues(\.firebaseFunctionParameter)
    }
    
    /// Calls firebase function with specified function call.
    /// - Parameter functionCall: Function call to call the firebase function.
    /// - Returns: Return data from firebase function.
    private func call<FunctionCall>(
        _ functionCall: FunctionCall
    ) async throws -> HTTPSCallableResult where FunctionCall: FFCallable {
        let parameters = try self.createParameters(of: functionCall)
        return try await Functions.functions(region: "europa-west1").httpsCallable(FunctionCall.functionName).call(parameters)
    }
    
    /// Calls firebase function with specified function call.
    /// - Parameter functionCall: Function call to call the firebase function.
    /// - Returns: Return data from firebase function.
    public func call<FunctionCall>(
        _ functionCall: FunctionCall
    ) async throws -> FunctionCall.ReturnType where FunctionCall: FFCallable {
        let decoder = FirebaseDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.dataDecodingStrategy = .base64
        let callResult: HTTPSCallableResult = try await self.call(functionCall)
        return try decoder.decode(FunctionCall.ReturnType.self, from: callResult.data)
    }
    
    /// Calls firebase function with specified function call.
    /// - Parameter functionCall: Function call to call the firebase function.
    public func call<FunctionCall>(
        _ functionCall: FunctionCall
    ) async throws where FunctionCall: FFCallable, FunctionCall.ReturnType == FFVoidReturnType {
        let _: HTTPSCallableResult = try await self.call(functionCall)
    }
    
    /// Sets the private key of the returned function called to specified provate key.
    /// - Parameter privateKey: Private key to set in the returned function caller.
    /// - Returns: Function caller with specified private key.
    public func privateKey(_ privateKey: String) -> FFCaller {
        var caller = self
        caller.privateKey = privateKey
        return caller
    }
    
    /// Sets the database type of the returned function called to `testing`.
    public var forTesting: FFCaller {
        var caller = self
        caller.databaseType = .testing
        return caller
    }
}

//
//  FFCaller.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation
import FirebaseFunctions
import CodableFirebase
import Crypter

/// Used to call firebase functions.
public struct FFCaller {
    
    /// Errors that can occur in a function call.
    enum CallError: Error {
        
        /// Cryption keys aren't set for function call
        case noCryptionKeys
        
        /// Private key isn't set for function call
        case noPrivateKey
        
        /// Return value of the function call isn't a string
        case returnValueNoString
    }
    
    /// Cryption keys for firebase function.
    private var cryptionKeys: Crypter.Keys?
    
    /// Private key for firebase function.
    private var privateKey: String?
    
    /// Type of the database for firebase function calls.
    private var databaseType: DatabaseType = .default
    
    /// Indicathes whether function call should be verbose.
    private var verboseCall: Bool = false
    
    /// Shared instance for singelton
    public static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Crypter to encrypt parameters and decrypt return value.
    private var crypter: Crypter {
        get throws {
            guard let cryptionKeys = self.cryptionKeys else {
                throw CallError.noCryptionKeys
            }
            return Crypter(keys: cryptionKeys)
        }
    }
    
    /// Creates the firebase function call parameters of specifed function call.
    /// Append private key and database type to parameters of specified function call.
    /// - Parameter functionCall: Function call to get other parameters from.
    /// - Returns: Firebase function call parameters of specifed function call.
    private func createParameters(
        of functionCall: some FFCallable
    ) throws -> FFParameters {
        guard let privateKey = self.privateKey else {
            throw CallError.noPrivateKey
        }
        @FFParametersBuilder var parameters: FFParameters {
            functionCall.parameters
            FFParameter(privateKey, for: "privateKey")
        }
        let encryptedParameters = try self.crypter.encodeEncrypt(parameters)
        @FFParametersBuilder var functionParameters: FFParameters {
            FFParameter(self.databaseType, for: "databaseType")
            FFParameter(self.verboseCall, for: "verbose")
            FFParameter(encryptedParameters, for: "parameters")
        }
        return functionParameters
    }
    
    /// Calls firebase function with specified function call.
    /// - Parameter functionCall: Function call to call the firebase function.
    /// - Returns: Return data from firebase function.
    public func call<FunctionCall>(
        _ functionCall: FunctionCall
    ) async throws -> FunctionCall.ReturnType where FunctionCall: FFCallable {
        let parameters = try self.createParameters(of: functionCall).functionParameters
        let callResult = try await Functions.functions(region: "europe-west1").httpsCallable(FunctionCall.functionName).call(parameters)
        guard let returnValue = callResult.data as? String else {
            throw CallError.returnValueNoString
        }
        let functionResult = try self.crypter.decryptDecode(type: FFCallResult<FunctionCall.ReturnType>.self, returnValue)
        return try functionResult.value
    }

    /// Calls firebase function with specified function call.
    /// - Parameter functionCall: Function call to call the firebase function.
    public func call<FunctionCall>(
        _ functionCall: FunctionCall
    ) async throws where FunctionCall: FFCallable, FunctionCall.ReturnType == FFVoidReturnType {
        let _: FunctionCall.ReturnType = try await self.call(functionCall)
    }

    /// Sets the cryption keys of the returned function called to specified cryption keys.
    /// - Parameter cryptionKeys: cryption keys to set in the returned function caller.
    /// - Returns: Function caller with specified cryption keys.
    public func cryptionKeys(_ cryptionKeys: Crypter.Keys) -> FFCaller {
        var caller = self
        caller.cryptionKeys = cryptionKeys
        return caller
    }
    
    /// Sets the private key of the returned function called to specified private key.
    /// - Parameter privateKey: Private key to set in the returned function caller.
    /// - Returns: Function caller with specified private key.
    public func privateKey(_ privateKey: String) -> FFCaller {
        var caller = self
        caller.privateKey = privateKey
        return caller
    }
    
    /// Sets the database type of the returned function called to `testing`.
    public var forTesting: FFCaller {
        var caller = self.verbose
        caller.databaseType = .testing
        return caller
    }
    
    /// Indicathes whether function call should be verbose.
    public var verbose: FFCaller {
        var caller = self
        caller.verboseCall = true
        return caller
    }
}

extension FFCaller {
    
    /// Error codes of a firebase function result error.
    public enum FFCallResultErrorCode: String, Decodable {
        case ok = "ok"
        case cancelled = "cancelled"
        case unknown = "unknown"
        case invalidArgument = "invalid-argument"
        case deadlineExceeded = "deadline-exceeded"
        case notFound = "not-found"
        case alreadyExists = "already-exists"
        case permissionDenied = "permission-denied"
        case resourceExhausted = "resource-exhausted"
        case failedPrecondition = "failed-precondition"
        case aborted = "aborted"
        case outOfRange = "out-of-range"
        case unimplemented = "unimplemented"
        case `internal` = "`internal`"
        case unavailable = "unavailable"
        case dataLoss = "data-loss"
        case unauthenticated = "unauthenticated"
    }
    
    /// Firebase function result error.
    public struct FFCallResultError: Error, Decodable {
        let code: FFCallResultErrorCode
        let message: String
        let stack: String?
    }
    
    /// Result of a firebase function call.
    internal enum FFCallResult<T> {
        
        /// Successful function call with return value.
        case success(value: T)
        
        /// Function call throws an error.
        case failure(error: FFCallResultError)
        
        /// Returns the success value as a throwing expression.
        public var value: T {
            get throws {
                switch self {
                case .success(value: let value): return value
                case .failure(error: let error): throw error
                }
            }
        }
    }
}

extension FFCaller.FFCallResult: Decodable where T: Decodable {
    private enum CodingKeys: String, CodingKey {
        case state
        case returnValue
        case error
    }
    
    private enum FFCallResultState: String, Decodable {
        case success
        case failure
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let state = try container.decode(FFCallResultState.self, forKey: .state)
        switch state {
        case .success:
            let value = try container.decode(T.self, forKey: .returnValue)
            self = .success(value: value)
        case .failure:
            let error = try container.decode(FFCaller.FFCallResultError.self, forKey: .error)
            self = .failure(error: error)
        }
    }
}

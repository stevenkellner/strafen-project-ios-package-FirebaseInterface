//
//  Utilities.swift
//  
//
//  Created by Steven on 14.06.22.
//

import XCTest
import FirebaseAuth
import StrafenProjectTypes
@testable import FirebaseInterface

extension XCTestCase {
    public func wait(seconds: Double = 60) {
        let expectation = self.expectation(description: "waiting_expectation")
        Task {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: seconds + 1)
    }
}

extension Bundle {
    func plist<T>(type: T.Type ,_ fileName: String) throws -> T? where T: Decodable {
        guard let path = self.path(forResource: fileName, ofType: "plist"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        let decoder = PropertyListDecoder()
        return try decoder.decode(type, from: data)
    }
}

extension FFCaller {
    static var testing: FFCaller {
        get throws {
            let secretsInfo = try Bundle.module.plist(type: SecretsInfo.self, "Secrets-Info")!
            return FFCaller.shared
                .cryptionKeys(secretsInfo.cryptionKeys.forTesting)
                .privateKey(secretsInfo.privateKey.forTesting)
                .forTesting
                .verbose
        }
    }
}

extension FRDFetcher {
    static var testing: FRDFetcher {
        get throws {
            let secretsInfo = try Bundle.module.plist(type: SecretsInfo.self, "Secrets-Info")!
            return FRDFetcher.shared
                .cryptionKeys(secretsInfo.cryptionKeys.forTesting)
                .forTesting
        }
    }
}
extension FRDObserver {
    static var testing: FRDObserver {
        get throws {
            let secretsInfo = try Bundle.module.plist(type: SecretsInfo.self, "Secrets-Info")!
            return FRDObserver.shared
                .cryptionKeys(secretsInfo.cryptionKeys.forTesting)
                .forTesting
        }
    }
}

extension FAuthenticator {
    @discardableResult
    public func signInTesting() async throws -> AuthDataResult {
        let secretsInfo = try Bundle.module.plist(type: SecretsInfo.self, "Secrets-Info")!
        return try await self.signIn(email: secretsInfo.testUser.email, password: secretsInfo.testUser.password)
    }
}

extension Date {
    public init?(isoString: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithMilliseconds
        guard let date = try? decoder.decode(Date.self, from: #""\#(isoString)""#.data(using: .utf8)!) else { return nil }
        self = date
    }
}

extension FRDFetcher.ListCounts: Equatable {
    public static func ==(lhs: FRDFetcher.ListCounts, rhs: FRDFetcher.ListCounts) -> Bool {
        return lhs.total == rhs.total && lhs.undeleted == rhs.undeleted
    }
}

extension FRDChildObservation.ChangeType: Equatable where T: Equatable {
    public static func ==(lhs: FRDChildObservation.ChangeType<T>, rhs: FRDChildObservation.ChangeType<T>) -> Bool {
        switch (lhs, rhs) {
        case (.added(value: let lhsValue), .added(value: let rhsValue)):
            return lhsValue == rhsValue
        case (.changed(value: let lhsValue), .changed(value: let rhsValue)):
            return lhsValue == rhsValue
        case (.removed(with: let lhsId), .removed(with: let rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}

//
//  FFGetClubIdCallTests.swift
//  
//
//  Created by Steven on 02.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFGetClubIdCallTests: XCTestCase {
    private let clubId = Club.ID(rawValue: UUID())

    override class func setUp() {
        FConfigurator.shared.configure(from: Bundle.module)
    }

    override func setUp() async throws {
        try await FAuthenticator.shared.signInTesting()
        let functionCall = FFNewTestClubCall(clubId: self.clubId, testClubType: .default)
        try await FFCaller.testing.call(functionCall)
    }

    override func tearDown() async throws {
        let functionCall = FFDeleteTestClubsCall()
        try await FFCaller.testing.call(functionCall)
        try FAuthenticator.shared.signOut()
    }

    func testWithExistingIdentifier() async throws {
        let functionCall = FFGetClubIdCall(identifier: "demo-team")
        let clubId = try await FFCaller.testing.call(functionCall)
        XCTAssertEqual(clubId, self.clubId)
    }

    func testWithNotExistingIdentifier() async throws {
        do {
            let functionCall = FFGetClubIdCall(identifier: "invalid")
            _ = try await FFCaller.testing.call(functionCall)
            XCTFail("A statement above should throw an error.")
        } catch let error as FFCaller.FFCallResultError {
            XCTAssertEqual(error.code, .notFound)
            XCTAssertEqual(error.message, "Club doesn't exists.")
        }
    }
}

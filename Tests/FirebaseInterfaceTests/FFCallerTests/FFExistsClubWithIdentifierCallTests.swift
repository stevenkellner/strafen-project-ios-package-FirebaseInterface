//
//  FFExistsClubWithIdentifierCallTests.swift
//  
//
//  Created by Steven on 02.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFExistsClubWithIdentifierCallTests: XCTestCase {
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
        let functionCall = FFExistsClubWithIdentifierCall(identifier: "demo-team")
        let existsClub = try await FFCaller.testing.call(functionCall)
        XCTAssertEqual(existsClub, true)
    }

    func testWithNotExistingIdentifier() async throws {
        let functionCall = FFExistsClubWithIdentifierCall(identifier: "invalid")
        let existsClub = try await FFCaller.testing.call(functionCall)
        XCTAssertEqual(existsClub, false)
    }
}

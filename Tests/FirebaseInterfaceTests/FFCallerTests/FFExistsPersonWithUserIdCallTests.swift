//
//  FFExistsPersonWithUserIdCallTests.swift
//  
//
//  Created by Steven on 02.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFExistsPersonWithUserIdCallTests: XCTestCase {
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

    func testWithExistingUserId() async throws {
        let functionCall = FFExistsPersonWithUserIdCall(userId: "LpAaeCz0BQfDHVYw02KiCyoTMS13")
        let existsPerson = try await FFCaller.testing.call(functionCall)
        XCTAssertEqual(existsPerson, true)
    }

    func testWithNotExistingUserId() async throws {
        let functionCall = FFExistsPersonWithUserIdCall(userId: "invalid")
        let existsPerson = try await FFCaller.testing.call(functionCall)
        XCTAssertEqual(existsPerson, false)
    }
}

//
//  FFGetPersonPropertiesCallTests.swift
//  
//
//  Created by Steven on 02.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFGetPersonPropertiesCallTests: XCTestCase {
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
        let functionCall = FFGetPersonPropertiesCall(userId: "LpAaeCz0BQfDHVYw02KiCyoTMS13")
        let properties = try await FFCaller.testing.call(functionCall)
        XCTAssertEqual(properties.clubProperties.id, self.clubId)
        XCTAssertEqual(properties.clubProperties.identifier, "demo-team")
        XCTAssertEqual(properties.clubProperties.inAppPaymentActive, true)
        XCTAssertEqual(properties.clubProperties.name, "Neuer Verein")
        XCTAssertEqual(properties.clubProperties.regionCode, "DE")
        XCTAssertEqual(properties.personProperties.id, Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
        XCTAssertEqual(properties.personProperties.isAdmin, true)
        XCTAssertEqual(properties.personProperties.name, FFPersonNameParameter(first: "Max", last: "Mustermann"))
        XCTAssertEqual(properties.personProperties.signInDate, Date(isoString: "2011-09-13T10:42:38 +0000"))
    }

    func testWithNotExistingIdentifier() async throws {
        do {
            let functionCall = FFGetPersonPropertiesCall(userId: "invalid")
            _ = try await FFCaller.testing.call(functionCall)
            XCTFail("A statement above should throw an error.")
        } catch let error as FFCaller.FFCallResultError {
            XCTAssertEqual(error.code, .notFound)
            XCTAssertEqual(error.message, "Person doesn't exist.")
        }
    }
}

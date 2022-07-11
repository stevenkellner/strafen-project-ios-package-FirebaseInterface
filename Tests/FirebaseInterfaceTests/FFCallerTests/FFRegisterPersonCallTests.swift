//
//  FFRegisterPersonCallTests.swift
//  
//
//  Created by Steven on 02.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFRegisterPersonCallTests: XCTestCase {
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

    func testRegisterNewPerson() async throws {

        // Register person
        let personId = Person.ID(rawValue: UUID())
        let signInDate = Date()
        let functionCall = FFRegisterPersonCall(
            clubId: self.clubId,
            personProperties: FFPersonPropertiesWithUserIdParameter(
                id: personId,
                signInDate: signInDate,
                userId: "opiuhj",
                name: FFPersonNameParameter(first: "ljk", last: "pkom")
            )
        )
        let clubProperties = try await FFCaller.testing.call(functionCall)

        // Check call result
        XCTAssertEqual(clubProperties.id, self.clubId)
        XCTAssertEqual(clubProperties.identifier, "demo-team")
        XCTAssertEqual(clubProperties.inAppPaymentActive, true)
        XCTAssertEqual(clubProperties.name, "Neuer Verein")
        XCTAssertEqual(clubProperties.regionCode, "DE")

        // Check database person user ids
        let fetchedPersonId = try await FRDFetcher.testing.fetch(Person.ID.self, from: URL(string: "\(self.clubId.uuidString)/personUserIds/opiuhj")!).value
        XCTAssertEqual(fetchedPersonId, personId)

        // Check database person
        let persons = try await FRDFetcher.testing.fetchPersons(of: self.clubId)
        XCTAssertEqual(
            persons[personId],
            Person(
                id: personId,
                name: PersonName(first: "ljk", last: "pkom"),
                signInData: SignInData(
                    admin: false,
                    signInDate: signInDate,
                    userId: "opiuhj"
                )
            )
        )
    }
}

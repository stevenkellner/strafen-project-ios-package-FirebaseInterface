//
//  FFForceSignOutCallTests.swift
//  
//
//  Created by Steven on 02.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFForceSignOutCallTests: XCTestCase {
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

    func testWithSignedInPerson() async throws {
        let personId = Person.ID(rawValue: UUID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!)
        let functionCall = FFForceSignOutCall(clubId: self.clubId, personId: personId)
        try await FFCaller.testing.call(functionCall)

        // Check sign in data
        let persons = try await FRDFetcher.testing.fetchPersons(of: self.clubId)
        XCTAssertEqual(persons[personId]?.signInData, nil)

        // Check person user ids
        let clubProperties = try await FRDFetcher.testing.fetchClub(with: self.clubId)
        XCTAssertEqual(clubProperties.personUserIds["asdnfl"], nil)
    }

    func testNoSignedInPerson() async throws {
        let functionCall = FFForceSignOutCall(clubId: self.clubId, personId: Person.ID(rawValue: UUID()))
        try await FFCaller.testing.call(functionCall)
    }
}

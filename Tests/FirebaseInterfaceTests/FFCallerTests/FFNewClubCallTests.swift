//
//  FFNewClubCallTests.swift
//  
//
//  Created by Steven on 01.07.22.
//

import XCTest
import Crypter
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFNewClubCallTests: XCTestCase {
    private let clubId = Club.ID(rawValue: UUID())
    
    override class func setUp() {
        FConfigurator.shared.configure(from: Bundle.module)
    }
    
    override func setUp() async throws {
        try await FAuthenticator.shared.signInTesting()
    }
    
    override func tearDown() async throws {
        let functionCall = FFDeleteTestClubsCall()
        try await FFCaller.testing.call(functionCall)
        try FAuthenticator.shared.signOut()
    }
    
    func testCreateNewClub() async throws {

        // Create new club
        let personId = Person.ID(rawValue: UUID())
        let signInDate = Date()
        let functionCall = FFNewClubCall(
            clubProperties: FFClubPropertiesParameter(
                id: self.clubId,
                name: "test club newClub1",
                identifier: "identifier_newClub1",
                regionCode: "DE",
                inAppPaymentActive: false
            ),
            personProperties: FFPersonPropertiesWithUserIdParameter(
                id: personId,
                signInDate: signInDate,
                userId: "test_person_userId",
                name: FFPersonNameParameter(first: "fn", last: "ln")
            )
        )
        try await FFCaller.testing.call(functionCall)
        
        // Check club properties
        let clubProperties = try await FRDFetcher.testing.fetchClub(with: self.clubId)
        let persons = try await FRDFetcher.testing.fetchPersons(of: self.clubId)
        let personsCount = try await FRDFetcher.testing.fetchPersonsCount(of: self.clubId)
        let reasonTemplatesCount = try await FRDFetcher.testing.fetchReasonTemplatesCount(of: self.clubId)
        let finesCount = try await FRDFetcher.testing.fetchFinesCount(of: self.clubId)
        XCTAssertEqual(clubProperties.identifier, "identifier_newClub1")
        XCTAssertEqual(clubProperties.name, "test club newClub1")
        XCTAssertEqual(clubProperties.regionCode, "DE")
        XCTAssertEqual(clubProperties.inAppPaymentActive, false)
        XCTAssertEqual(clubProperties.personUserIds, ["test_person_userId": personId])
        XCTAssertEqual(
            persons[personId],
            Person(
                id: personId,
                name: PersonName(first: "fn", last: "ln"),
                signInData: SignInData(
                    admin: true,
                    signInDate: signInDate,
                    userId: "test_person_userId"
                )
            )
        )
        XCTAssertEqual(personsCount, Person.Count(rawValue: FRDFetcher.ListCounts(total: 1, undeleted: 1)))
        XCTAssertEqual(reasonTemplatesCount, ReasonTemplate.Count(rawValue: FRDFetcher.ListCounts(total: 0, undeleted: 0)))
        XCTAssertEqual(finesCount, Fine.Count(rawValue: FRDFetcher.ListCounts(total: 0, undeleted: 0)))
    }

    func testExistingIdentifier() async throws {

        // Create first club
        let personId = Person.ID(rawValue: UUID())
        let signInDate = Date()
        let functionCall1 = FFNewClubCall(
            clubProperties: FFClubPropertiesParameter(
                id: self.clubId,
                name: "kdkdodm",
                identifier: "identifier",
                regionCode: "DE",
                inAppPaymentActive: false
            ),
            personProperties: FFPersonPropertiesWithUserIdParameter(
                id: personId,
                signInDate: signInDate,
                userId: "userId_1",
                name: FFPersonNameParameter(first: "fn", last: "ln")
            )
        )
        try await FFCaller.testing.call(functionCall1)

        // Check club properties to be available
        let _ = try await FRDFetcher.testing.fetchClub(with: self.clubId)

        // Try create club with same identifier
        let functionCall2 = FFNewClubCall(
            clubProperties: FFClubPropertiesParameter(
                id: self.clubId,
                name: "joiuzghj",
                identifier: "identifier",
                regionCode: "DE",
                inAppPaymentActive: false
            ),
            personProperties: FFPersonPropertiesWithUserIdParameter(
                id: personId,
                signInDate: signInDate,
                userId: "userId_2",
                name: FFPersonNameParameter(first: "fn", last: "ln")
            )
        )
        do {
            try await FFCaller.testing.call(functionCall2)
            XCTFail("A statement above should throw an error.")
        } catch let error as FFCaller.FFCallResultError {
            XCTAssertEqual(error.code, .alreadyExists)
            XCTAssertEqual(error.message, "Club identifier already exists")
        }
    }

    func testSameId() async throws {

        // Create first club
        let personId = Person.ID(rawValue: UUID())
        let signInDate = Date()
        let functionCall1 = FFNewClubCall(
            clubProperties: FFClubPropertiesParameter(
                id: self.clubId,
                name: "kdkdodm",
                identifier: "identifier1",
                regionCode: "DE",
                inAppPaymentActive: false
            ),
            personProperties: FFPersonPropertiesWithUserIdParameter(
                id: personId,
                signInDate: signInDate,
                userId: "userId_1",
                name: FFPersonNameParameter(first: "fn", last: "ln")
            )
        )
        try await FFCaller.testing.call(functionCall1)

        // Check club properties to be available
        let _ = try await FRDFetcher.testing.fetchClub(with: self.clubId)

        // Create second club
        let functionCall2 = FFNewClubCall(
            clubProperties: FFClubPropertiesParameter(
                id: self.clubId,
                name: "iuohj",
                identifier: "identifier2",
                regionCode: "DE",
                inAppPaymentActive: true
            ),
            personProperties: FFPersonPropertiesWithUserIdParameter(
                id: personId,
                signInDate: signInDate,
                userId: "userId_2",
                name: FFPersonNameParameter(first: "fn_", last: "ln_")
            )
        )
        try await FFCaller.testing.call(functionCall2)

        // Check club properties
        let clubProperties = try await FRDFetcher.testing.fetchClub(with: self.clubId)
        let persons = try await FRDFetcher.testing.fetchPersons(of: self.clubId)
        XCTAssertEqual(clubProperties.identifier, "identifier1")
        XCTAssertEqual(clubProperties.name, "kdkdodm")
        XCTAssertEqual(clubProperties.regionCode, "DE")
        XCTAssertEqual(clubProperties.inAppPaymentActive, false)
        XCTAssertEqual(clubProperties.personUserIds, ["userId_1": personId])
        XCTAssertEqual(
            persons[personId],
            Person(
                id: personId,
                name: PersonName(first: "fn", last: "ln"),
                signInData: SignInData(
                    admin: true,
                    signInDate: signInDate,
                    userId: "userId_1"
                )
            )
        )
    }
}

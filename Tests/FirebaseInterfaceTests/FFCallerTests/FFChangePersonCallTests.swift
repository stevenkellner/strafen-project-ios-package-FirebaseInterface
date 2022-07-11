//
//  FFChangePersonCallTests.swift
//  
//
//  Created by Steven on 03.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFChangePersonCallTests: XCTestCase {
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

    func testDeleteAlreadySignedIn() async throws {
        do {
            let functionCall = FFChangePersonCall(
                clubId: self.clubId,
                changeType: .delete,
                updatablePerson: FFUpdatableParameter(
                    property: FFDeletableParameter.deleted(with: Person.ID(rawValue: UUID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!)),
                    updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                        timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!,
                        personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                    )
                )
            )
            try await FFCaller.testing.call(functionCall)
            XCTFail("A statement above should throw an error.")
        } catch let error as FFCaller.FFCallResultError {
            XCTAssertEqual(error.code, .unavailable)
            XCTAssertEqual(error.message, "Person is already signed in!")
        }
    }

    private func setPerson(variant: Bool, timestamp: Date) async throws -> Person {
        let personId = Person.ID(rawValue: UUID(uuidString: "61756c29-ac8a-4471-a283-4dde2623a1b9")!)
        let person = variant ?
            FFPersonParameter(id: personId, name: FFPersonNameParameter(first: "ojiölkm", last: "0oijklm")) :
            FFPersonParameter(id: personId, name: FFPersonNameParameter(first: "pok", last: "7t78inmk"))
        let functionCall = FFChangePersonCall(
            clubId: self.clubId,
            changeType: .update,
            updatablePerson: FFUpdatableParameter(
                property: FFDeletableParameter.item(value: person),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: timestamp,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check person
        let persons = try await FRDFetcher.testing.fetchPersons(of: self.clubId)
        XCTAssertEqual(persons[personId], Person(person))
        return Person(person)
    }

    func testPersonSet() async throws {
        let _ = try await self.setPerson(variant: false, timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!)

        // Check persons count
        let personsCount = try await FRDFetcher.testing.fetchPersonsCount(of: self.clubId)
        XCTAssertEqual(personsCount, Person.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO
    }

    func testPersonUpdate() async throws {
        let _ = try await self.setPerson(variant: false, timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!)
        let _ = try await self.setPerson(variant: true, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)

        // Check persons count
        let personsCount = try await FRDFetcher.testing.fetchPersonsCount(of: self.clubId)
        XCTAssertEqual(personsCount, Person.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO
    }

    func testPersonDelete() async throws {
        let person = try await self.setPerson(variant: true, timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!)
        let functionCall = FFChangePersonCall(
            clubId: self.clubId,
            changeType: .delete,
            updatablePerson: FFUpdatableParameter(
                property: FFDeletableParameter.deleted(with: person.id),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check person
        let persons = try await FRDFetcher.testing.fetchPersons(of: self.clubId)
        XCTAssertEqual(persons[person.id], nil)

        // Check persons count
        let personsCount = try await FRDFetcher.testing.fetchPersonsCount(of: self.clubId)
        XCTAssertEqual(personsCount, Person.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 3)))

        // Check statistics TODO
    }
}

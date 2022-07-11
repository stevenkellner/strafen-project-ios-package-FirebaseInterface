//
//  FFChangeFineCallTests.swift
//  
//
//  Created by Steven on 17.06.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFChangeFineCallTests: XCTestCase {
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

    private func addReasonTemplate() async throws {
        let id = ReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!)
        let reasonTemplate = FFReasonTemplateParameter(
            id: id,
            reasonMessage: "Reason 1",
            amount: FFAmountParameter(value: 12, subUnitValue: 50),
            importance: .medium
        )
        let functionCall = FFChangeReasonTemplateCall(
            clubId: self.clubId,
            changeType: .update,
            updatableReasonTemplate: FFUpdatableParameter(
                property: .item(value: reasonTemplate),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check reason template
        let reasonTemplates = try await FRDFetcher.testing.fetchReasonTemplates(of: self.clubId)
        XCTAssertEqual(reasonTemplates[id], ReasonTemplate(reasonTemplate))
    }

    private func setFine(withTemplate: Bool, timestamp: Date) async throws -> Fine {
        let id = Fine.ID(rawValue: UUID(uuidString: "637d6187-68d2-4000-9cb8-7dfc3877d5ba")!)
        let associatedPersonId = Person.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        let reasonTemplateId = ReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!)
        let fine = FFFineParameter(
            id: id,
            personId: associatedPersonId,
            payedState: .unpayed,
            number: 2,
            date: Date(isoString: "2011-10-14T10:42:38+0000")!,
            fineReason: withTemplate ?
                .template(reasonTemplateId: reasonTemplateId) :
                    .custom(reasonMessage: "Reason 2", amount: FFAmountParameter(value: 3, subUnitValue: 10), importance: .low)
        )
        let functionCall = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .update,
            updatableFine: FFUpdatableParameter(
                property: .item(value: fine),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: timestamp, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check fine
        let fines = try await FRDFetcher.testing.fetchFines(of: self.clubId)
        XCTAssertEqual(fines[id], Fine(fine))
        return Fine(fine)
    }

    func testFineSet() async throws {
        try await self.addReasonTemplate()
        let _ = try await self.setFine(withTemplate: true, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)

        // Check fines count
        let finesCount = try await FRDFetcher.testing.fetchFinesCount(of: self.clubId)
        XCTAssertEqual(finesCount, Fine.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO
    }

    func testFineUpdateCustomReason() async throws {
        try await self.addReasonTemplate()
        let _ = try await self.setFine(withTemplate: true, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)
        let _ = try await self.setFine(withTemplate: false, timestamp: Date(isoString: "2011-10-16T10:42:38+0000")!)

        // Check fines count
        let finesCount = try await FRDFetcher.testing.fetchFinesCount(of: self.clubId)
        XCTAssertEqual(finesCount, Fine.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO
    }

    func testFineUpdateReasonTemplate() async throws {
        try await self.addReasonTemplate()
        let _ = try await self.setFine(withTemplate: false, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)
        let _ = try await self.setFine(withTemplate: true, timestamp: Date(isoString: "2011-10-16T10:42:38+0000")!)

        // Check fines count
        let finesCount = try await FRDFetcher.testing.fetchFinesCount(of: self.clubId)
        XCTAssertEqual(finesCount, Fine.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO
    }

    func testFineDelete() async throws {
        try await self.addReasonTemplate()
        let fine = try await self.setFine(withTemplate: true, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)

        // Delete fine
        let functionCall = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableFine: FFUpdatableParameter(
                property: .deleted(with: fine.id),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-16T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check fine
        let fines = try await FRDFetcher.testing.fetchFines(of: self.clubId)
        XCTAssertEqual(fines[fine.id], nil)

        // Check fines count
        let finesCount = try await FRDFetcher.testing.fetchFinesCount(of: self.clubId)
        XCTAssertEqual(finesCount, Fine.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 3)))

        // Check statistics TODO
    }

    func testUpdateDeletedFine() async throws {
        try await self.addReasonTemplate()
        let fine = try await self.setFine(withTemplate: true, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)

        // Delete fine
        let functionCall = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableFine: FFUpdatableParameter(
                property: .deleted(with: fine.id),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-16T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check fine
        let fines = try await FRDFetcher.testing.fetchFines(of: self.clubId)
        XCTAssertEqual(fines[fine.id], nil)

        // Update fine
        let _ = try await self.setFine(withTemplate: true, timestamp: Date(isoString: "2011-10-16T10:42:39+0000")!)

        // Check fines count
        let finesCount = try await FRDFetcher.testing.fetchFinesCount(of: self.clubId)
        XCTAssertEqual(finesCount, Fine.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO

    }
}

//
//  FFChangeFinePayedCallTests.swift
//  
//
//  Created by Steven on 04.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFChangeFinePayedCallTests: XCTestCase {
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

    private func addFinesAndReasonTemplate() async throws -> (fine1: Fine, fine2: Fine) {

        // Add reason template
        let reasonTemplateId = ReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!)
        let reasonTemplate = FFReasonTemplateParameter(
            id: reasonTemplateId,
            reasonMessage: "Message 1",
            amount: FFAmountParameter(value: 34, subUnitValue: 1),
            importance: .low
        )
        let reasonTemplateFunctionCall = FFChangeReasonTemplateCall(
            clubId: self.clubId,
            changeType: .update,
            updatableReasonTemplate: FFUpdatableParameter(
                property: .item(value: reasonTemplate),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(reasonTemplateFunctionCall)

        // Add fine 1
        let fine1Id = Fine.ID(rawValue: UUID(uuidString: "637d6187-68d2-4000-9cb8-7dfc3877d5ba")!)
        let fine1PersonId = Person.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        let fine1 = FFFineParameter(
            id: fine1Id,
            personId: fine1PersonId,
            payedState: .unpayed,
            number: 2,
            date: Date(isoString: "2011-10-14T10:42:38+0000")!,
            fineReason: .template(reasonTemplateId: reasonTemplateId)
        )
        let fine1FunctionCall = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .update,
            updatableFine: FFUpdatableParameter(
                property: .item(value: fine1),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(fine1FunctionCall)

        // Add fine 2
        let fine2Id = Fine.ID(rawValue: UUID(uuidString: "137d6187-68d2-4000-9cb8-7dfc3877d5ba")!)
        let fine2PersonId = Person.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        let fine2 = FFFineParameter(
            id: fine2Id,
            personId: fine2PersonId,
            payedState: .unpayed,
            number: 2,
            date: Date(isoString: "2011-10-14T10:42:48+0000")!,
            fineReason: .custom(reasonMessage: "Message 1", amount: FFAmountParameter(value: 4), importance: .medium)
        )
        let fine2FunctionCall = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .update,
            updatableFine: FFUpdatableParameter(
                property: .item(value: fine2),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(fine2FunctionCall)

        // Check fines and reason template
        let fines = try await FRDFetcher.testing.fetchFines(of: self.clubId)
        let reasonTemplates = try await FRDFetcher.testing.fetchReasonTemplates(of: self.clubId)
        XCTAssertEqual(fines[fine1Id], Fine(fine1))
        XCTAssertEqual(fines[fine2Id], Fine(fine2))
        XCTAssertEqual(reasonTemplates[reasonTemplateId], ReasonTemplate(reasonTemplate))
        return (fine1: Fine(fine1), fine2: Fine(fine2))
    }

    private func changeFinePayed(to payedState: FFPayedStateParameter, fineId: Fine.ID) async throws {

        // Change fine payed
        let functionCall = FFChangeFinePayedCall(
            clubId: self.clubId,
            fineId: fineId,
            payedState: payedState,
            fineUpdateProperties: FFUpdatableParameter<Any>.UpdateProperties(timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
        )
        try await FFCaller.testing.call(functionCall)

        // Check fine payed
        let fines = try await FRDFetcher.testing.fetchFines(of: self.clubId)
        XCTAssertEqual(fines[fineId]?.payedState, PayedState(payedState))

        // Check statistics TODO
    }

    func testToPayed1() async throws {
        let (fine, _) = try await self.addFinesAndReasonTemplate()
        let payedState: FFPayedStateParameter = .payed(inApp: false, payDate: Date(isoString: "2011-10-14T10:42:38+0000")!)
        try await self.changeFinePayed(to: payedState, fineId: fine.id)
    }

    func testToPayed2() async throws {
        let (_, fine) = try await self.addFinesAndReasonTemplate()
        let payedState: FFPayedStateParameter = .payed(inApp: true, payDate: Date(isoString: "2011-10-14T10:42:38+0000")!)
        try await self.changeFinePayed(to: payedState, fineId: fine.id)
    }

    func testToUnpayed() async throws {
        let (fine, _) = try await self.addFinesAndReasonTemplate()
        let payedState: FFPayedStateParameter = .unpayed
        try await self.changeFinePayed(to: payedState, fineId: fine.id)
    }

    func testToSettled() async throws {
        let (fine, _) = try await self.addFinesAndReasonTemplate()
        let payedState: FFPayedStateParameter = .settled
        try await self.changeFinePayed(to: payedState, fineId: fine.id)
    }

    func testChangeOfDeletedFine() async throws {
        let (fine, _) = try await self.addFinesAndReasonTemplate()

        // Delete fine
        let functionCall1 = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableFine: FFUpdatableParameter(
                property: .deleted(with: fine.id),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall1)

        // Check fine
        let fines = try await FRDFetcher.testing.fetchFines(of: self.clubId)
        XCTAssertEqual(fines[fine.id], nil)

        // Change fine payed
        let functionCall2 = FFChangeFinePayedCall(
            clubId: self.clubId,
            fineId: fine.id,
            payedState: .unpayed,
            fineUpdateProperties: FFUpdatableParameter<Any>.UpdateProperties(timestamp: Date(isoString: "2011-10-15T10:42:39+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
        )
        do {
            _ = try await FFCaller.testing.call(functionCall2)
            XCTFail("A statement above should throw an error.")
        } catch let error as FFCaller.FFCallResultError {
            XCTAssertEqual(error.code, .unavailable)
            XCTAssertEqual(error.message, "Couldn't get fine from 'Deleted'.")
        }
    }
}

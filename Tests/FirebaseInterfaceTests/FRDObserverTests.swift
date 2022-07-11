//
//  FRDObserverTests.swift
//  
//
//  Created by Steven on 04.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FRDObserverTests: XCTestCase {
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

    func testPersonObservation() async throws {
        let totalPersonsCount = try await FRDFetcher.testing.fetchPersonsCount(of: self.clubId).total
        let observation = try FRDObserver.testing.observePersons(of: self.clubId, ignore: totalPersonsCount)
        var observedChangeType: FRDChildObservation<Deletable<Person>>.ChangeType<Person>? = nil
        observation.addObserver { result in
            switch result {
            case .failure(let error):
                XCTFail("Result failed with: \(error)")
            case .success(let changeType):
                observedChangeType = changeType
            }
        }

        // Add person
        let id = Person.ID(rawValue: UUID())
        let functionCall1 = FFChangePersonCall(
            clubId: self.clubId,
            changeType: .update,
            updatablePerson: FFUpdatableParameter(
                property: .item(value: FFPersonParameter(id: id, name: FFPersonNameParameter(first: "asd", last: "ouih"))),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:42:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall1)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .added(value: Person(id: id, name: PersonName(first: "asd", last: "ouih"), signInData: nil)))

        // Update person
        let functionCall2 = FFChangePersonCall(
            clubId: self.clubId,
            changeType: .update,
            updatablePerson: FFUpdatableParameter(
                property: .item(value: FFPersonParameter(id: id, name: FFPersonNameParameter(first: "lih", last: "vcxb"))),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:43:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall2)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .changed(value: Person(id: id, name: PersonName(first: "lih", last: "vcxb"), signInData: nil)))

        // Delete person
        let functionCall3 = FFChangePersonCall(
            clubId: self.clubId,
            changeType: .delete,
            updatablePerson: FFUpdatableParameter(
                property: .deleted(with: id),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:44:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall3)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .removed(with: id))

        observation.stopObservating()
    }

    func testReasonTemplateObservation() async throws {
        let totalReasonTemplatesCount = try await FRDFetcher.testing.fetchReasonTemplatesCount(of: self.clubId).total
        let observation = try FRDObserver.testing.observeReasonTemplates(of: self.clubId, ignore: totalReasonTemplatesCount)
        var observedChangeType: FRDChildObservation<Deletable<ReasonTemplate>>.ChangeType<ReasonTemplate>? = nil
        observation.addObserver { result in
            switch result {
            case .failure(let error):
                XCTFail("Result failed with: \(error)")
            case .success(let changeType):
                observedChangeType = changeType
            }
        }

        // Add reason template
        let id = ReasonTemplate.ID(rawValue: UUID())
        let functionCall1 = FFChangeReasonTemplateCall(
            clubId: self.clubId,
            changeType: .update,
            updatableReasonTemplate: FFUpdatableParameter(
                property: .item(value: FFReasonTemplateParameter(id: id, reasonMessage: "asdf", amount: FFAmountParameter(value: 12, subUnitValue: 90), importance: .low)),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:42:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall1)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .added(value: ReasonTemplate(id: id, reasonMessage: "asdf", amount: Amount(value: 12, subUnitValue: 90), importance: .low)))

        // Update reason template
        let functionCall2 = FFChangeReasonTemplateCall(
            clubId: self.clubId,
            changeType: .update,
            updatableReasonTemplate: FFUpdatableParameter(
                property: .item(value: FFReasonTemplateParameter(id: id, reasonMessage: "nzruzt", amount: FFAmountParameter(value: 2, subUnitValue: 15), importance: .medium)),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:43:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall2)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .changed(value: ReasonTemplate(id: id, reasonMessage: "nzruzt", amount: Amount(value: 2, subUnitValue: 15), importance: .medium)))

        // Delete reason template
        let functionCall3 = FFChangeReasonTemplateCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableReasonTemplate: FFUpdatableParameter(
                property: .deleted(with: id),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:44:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall3)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .removed(with: id))

        observation.stopObservating()
    }

    func testFineObservation() async throws {
        let totalFinesCount = try await FRDFetcher.testing.fetchFinesCount(of: self.clubId).total
        let observation = try FRDObserver.testing.observeFines(of: self.clubId, ignore: totalFinesCount)
        var observedChangeType: FRDChildObservation<Deletable<Fine>>.ChangeType<Fine>? = nil
        observation.addObserver { result in
            switch result {
            case .failure(let error):
                XCTFail("Result failed with: \(error)")
            case .success(let changeType):
                observedChangeType = changeType
            }
        }

        // Add fine
        let id = Fine.ID(rawValue: UUID())
        let personId = Person.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        let date = Date()
        let functionCall1 = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .update,
            updatableFine: FFUpdatableParameter(
                property: .item(value: FFFineParameter(id: id, personId: personId, payedState: .settled, number: 3, date: date, fineReason: .custom(reasonMessage: "asf", amount: FFAmountParameter(value: 9, subUnitValue: 10), importance: .high))),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:42:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall1)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .added(value: Fine(id: id, personId: personId, payedState: .settled, number: 3, date: date, fineReason: .custom(reasonMessage: "asf", amount: Amount(value: 9, subUnitValue: 10), importance: .high))))

        // Update fine
        let functionCall2 = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .update,
            updatableFine: FFUpdatableParameter(
                property: .item(value: FFFineParameter(id: id, personId: personId, payedState: .unpayed, number: 1, date: date, fineReason: .custom(reasonMessage: "dbsg", amount: FFAmountParameter(value: 0, subUnitValue: 1), importance: .low))),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:43:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall2)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .changed(value: Fine(id: id, personId: personId, payedState: .unpayed, number: 1, date: date, fineReason: .custom(reasonMessage: "dbsg", amount: Amount(value: 0, subUnitValue: 1), importance: .low))))

        // Delete fine
        let functionCall3 = FFChangeFineCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableFine: FFUpdatableParameter(
                property: .deleted(with: id),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:44:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall3)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedChangeType, .removed(with: id))

        observation.stopObservating()
    }

    func testLatePaymentInterestObservation() async throws {
        let observation = try FRDObserver.testing.observeLatePaymentInterest(of: self.clubId)
        var observedInterest: LatePaymentInterest?
        observation.addObserver { result in
            switch result {
            case .failure(let error):
                XCTFail("Result failed with: \(error)")
            case .success(let changeType):
                observedInterest = changeType
            }
        }

        // Add interest
        let functionCall1 = FFChangeLatePaymentInterestCall(
            clubId: self.clubId,
            changeType: .update,
            updatableInterest: FFUpdatableParameter(
                property: .item(value: FFLatePaymentInterestParameter(interestFreePeriod: FFLatePaymentInterestParameter.TimePeriod(value: 1, unit: .day), interestPeriod: FFLatePaymentInterestParameter.TimePeriod(value: 2, unit: .month), interestRate: 1.2, compoundInterest: false)),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:42:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall1)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedInterest, LatePaymentInterest(interestFreePeriod: TimePeriod(value: 1, unit: .day), interestPeriod: TimePeriod(value: 2, unit: .month), interestRate: 1.2, compoundInterest: false))

        // Update interest
        let functionCall2 = FFChangeLatePaymentInterestCall(
            clubId: self.clubId,
            changeType: .update,
            updatableInterest: FFUpdatableParameter(
                property: .item(value: FFLatePaymentInterestParameter(interestFreePeriod: FFLatePaymentInterestParameter.TimePeriod(value: 3, unit: .month), interestPeriod: FFLatePaymentInterestParameter.TimePeriod(value: 4, unit: .year), interestRate: 0.1, compoundInterest: true)),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:43:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall2)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedInterest, LatePaymentInterest(interestFreePeriod: TimePeriod(value: 3, unit: .month), interestPeriod: TimePeriod(value: 4, unit: .year), interestRate: 0.1, compoundInterest: true))

        // Delete interest
        let functionCall3 = FFChangeLatePaymentInterestCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableInterest: FFUpdatableParameter(
                property: .deleted(with: nil),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(
                    timestamp: Date(isoString: "2012-10-15T10:44:38+0000")!,
                    personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)
                )
            )
        )
        try await FFCaller.testing.call(functionCall3)
        self.wait(seconds: 2.5)
        XCTAssertEqual(observedInterest, nil)

        observation.stopObservating()
    }
}

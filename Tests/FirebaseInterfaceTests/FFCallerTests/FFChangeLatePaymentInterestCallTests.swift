//
//  FFChangeLatePaymentInterestCallTests.swift
//  
//
//  Created by Steven on 03.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFChangeLatePaymentInterestCallTests: XCTestCase {
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

    private func setInterest(variant: Bool, timestamp: Date) async throws -> LatePaymentInterest {
        let interest = variant ?
            FFLatePaymentInterestParameter(
                interestFreePeriod: FFLatePaymentInterestParameter.TimePeriod(value: 1, unit: .month),
                interestPeriod: FFLatePaymentInterestParameter.TimePeriod(value: 5, unit: .day),
                interestRate: 0.12,
                compoundInterest: false
            ) :
        FFLatePaymentInterestParameter(
            interestFreePeriod: FFLatePaymentInterestParameter.TimePeriod(value: 2, unit: .year),
            interestPeriod: FFLatePaymentInterestParameter.TimePeriod(value: 3, unit: .month),
            interestRate: 0.05,
            compoundInterest: true
        )
        let functionCall = FFChangeLatePaymentInterestCall(
            clubId: self.clubId,
            changeType: .update,
            updatableInterest: FFUpdatableParameter(
                property: .item(value: interest),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: timestamp, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check interest
        let fetchedInterest = try await FRDFetcher.testing.fetchLatePaymentInterest(of: self.clubId)
        XCTAssertEqual(fetchedInterest, LatePaymentInterest(interest))

        return LatePaymentInterest(interest)
    }

    func testInterestSet() async throws {
        let _ = try await self.setInterest(variant: false, timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!)

        // Check statistic TODO
    }

    func testInterestUpdate() async throws {
        let _ = try await self.setInterest(variant: false, timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!)
        let _ = try await self.setInterest(variant: false, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)

        // Check statistic TODO
    }

    func testInterestDelete() async throws {
        let _ = try await self.setInterest(variant: false, timestamp: Date(isoString: "2011-10-14T10:42:38+0000")!)

        // Delete interst
        let functionCall = FFChangeLatePaymentInterestCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableInterest: FFUpdatableParameter(
                property: .deleted(with: nil),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check interest
        let fetchedInterest = try await FRDFetcher.testing.fetchLatePaymentInterest(of: self.clubId)
        XCTAssertEqual(fetchedInterest, nil)

        // Check statistic TODO
    }

    func testInterestDeleteBeforeAdding() async throws {
        let functionCall = FFChangeLatePaymentInterestCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableInterest: FFUpdatableParameter(
                property: .deleted(with: nil),
                updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
            )
        )
        try await FFCaller.testing.call(functionCall)

        // Check interest
        let fetchedInterest = try await FRDFetcher.testing.fetchLatePaymentInterest(of: self.clubId)
        XCTAssertEqual(fetchedInterest, nil)
    }
}

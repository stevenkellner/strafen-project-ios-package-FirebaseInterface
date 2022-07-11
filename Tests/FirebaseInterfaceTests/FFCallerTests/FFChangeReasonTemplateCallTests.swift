//
//  FFChangeReasonTemplateCallTests.swift
//  
//
//  Created by Steven on 02.07.22.
//

import XCTest
import StrafenProjectTypes
@testable import FirebaseInterface

final class FFChangeReasonTemplateCallTests: XCTestCase {
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
    
    private func setReasonTemplate(variant: Bool, timestamp: Date) async throws -> ReasonTemplate {
        let reasonTemplateId = ReasonTemplate.ID(rawValue: UUID(uuidString: "18ae484f-a1b7-456b-807e-339ff6679ad0")!)
        let reasonTemplate = variant ?
            FFReasonTemplateParameter(
                id: reasonTemplateId,
                reasonMessage: "Reason",
                amount: FFAmountParameter(value: 1, subUnitValue: 50),
                importance: .high
            ) :
            FFReasonTemplateParameter(
                id: reasonTemplateId,
                reasonMessage: "Reason asdf",
                amount: FFAmountParameter(value: 150),
                importance: .medium
            )
        let updatableReasonTemplate = FFUpdatableParameter(
            property: FFDeletableParameter<FFReasonTemplateParameter, ReasonTemplate.ID>.item(value: reasonTemplate),
            updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: timestamp, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
        )
        let functionCall = FFChangeReasonTemplateCall(
            clubId: self.clubId,
            changeType: .update,
            updatableReasonTemplate: updatableReasonTemplate
        )
        try await FFCaller.testing.call(functionCall)

        // Check reason template
        let reasonTemplates = try await FRDFetcher.testing.fetchReasonTemplates(of: self.clubId)
        XCTAssertEqual(
            reasonTemplates[reasonTemplateId],
            ReasonTemplate(reasonTemplate)
        )

        return ReasonTemplate(reasonTemplate)
    }

    func testReasonTemplateSet() async throws {
        let _ = try await self.setReasonTemplate(variant: false, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)

        // Check reason template count
        let reasonTemplatesCount = try await FRDFetcher.testing.fetchReasonTemplatesCount(of: self.clubId)
        XCTAssertEqual(reasonTemplatesCount, ReasonTemplate.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO
    }

    func testReasonTemplateUpdate() async throws {
        let _ = try await self.setReasonTemplate(variant: false, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)
        let _ = try await self.setReasonTemplate(variant: true, timestamp: Date(isoString: "2011-10-16T10:42:38+0000")!)

        // Check reason template count
        let reasonTemplatesCount = try await FRDFetcher.testing.fetchReasonTemplatesCount(of: self.clubId)
        XCTAssertEqual(reasonTemplatesCount, ReasonTemplate.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 4)))

        // Check statistics TODO
    }

    func testReasonTemplateDelete() async throws {
        let reasonTemplate = try await self.setReasonTemplate(variant: true, timestamp: Date(isoString: "2011-10-15T10:42:38+0000")!)
        let updatableReasonTemplate = FFUpdatableParameter(
            property: FFDeletableParameter<FFReasonTemplateParameter, ReasonTemplate.ID>.deleted(with: reasonTemplate.id),
            updateProperties: FFUpdatableParameter<_>.UpdateProperties(timestamp: Date(isoString: "2011-10-16T10:42:38+0000")!, personId: Person.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!))
        )
        let functionCall = FFChangeReasonTemplateCall(
            clubId: self.clubId,
            changeType: .delete,
            updatableReasonTemplate: updatableReasonTemplate
        )
        try await FFCaller.testing.call(functionCall)

        // Check reason template
        let reasonTemplates = try await FRDFetcher.testing.fetchReasonTemplates(of: self.clubId)
        XCTAssertEqual(reasonTemplates[reasonTemplate.id], nil)

        // Check reason template count
        let reasonTemplatesCount = try await FRDFetcher.testing.fetchReasonTemplatesCount(of: self.clubId)
        XCTAssertEqual(reasonTemplatesCount, ReasonTemplate.Count(rawValue: FRDFetcher.ListCounts(total: 4, undeleted: 3)))

        // Check statistics TODO
    }
}

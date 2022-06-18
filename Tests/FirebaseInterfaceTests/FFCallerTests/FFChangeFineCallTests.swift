//
//  FFChangeFineCallTests.swift
//  
//
//  Created by Steven on 17.06.22.
//

import XCTest
@testable import FirebaseInterface

final class FFChangeFineCallTests: XCTestCase {
    
    private let clubId = UUID()
    
    override class func setUp() {
        FConfigurator.shared.configure()
    }
    
    override func setUp() async throws {
        try await FAuthenticator.shared.signInTesting()
        let functionCall = FFNewTestClubCall(clubId: self.clubId, testClubType: .default)
        try await FFCaller.shared.callTesting(functionCall)
    }

    override func tearDown() async throws {
        let functionCall = FFDeleteTestClubsCall()
        try await FFCaller.shared.callTesting(functionCall)
        try FAuthenticator.shared.signOut()
    }
    
    private func addReasonTemplate() async throws {
        let reasonTemplateId = UUID()
        let timestamp = Date()
        let personId = UUID()
        let reasonTemplate = FFReasonTemplateParameter(id: reasonTemplateId, reasonMessage: "Test Reason Message", amount: FFAmountParameter(value: 12, subUnitValue: 34), importance: .medium)
        let deletableReasonTemplate: FFDeletableParameter<FFReasonTemplateParameter, UUID> = .item(reasonTemplate)
        let updatableReasonTemplate = FFUpdatableParameter(property: deletableReasonTemplate, updateProperties: FFUpdatableParameter.UpdateProperties(timestamp: timestamp, personId: personId))
        let functionCall = FFChangeReasonTemplateCall(clubId: self.clubId, changeType: .update, updatableReasonTemplate: updatableReasonTemplate)
        try await FFCaller.shared.callTesting(functionCall)
        
        let reasonList = try await FRDFetcher.shared.fetchReasonTemplatessTesting(of: self.clubId)
        let fetchedReasonTemplate = reasonList[reasonTemplateId.uuidString]
    }
}




extension FRDAmount: IAmount {}

extension FRDImportance: IImportance {
    var concreteImportance: Importance {
        switch self {
        case .high: return .high
        case .medium: return .medium
        case .low: return .low
        }
    }
}

struct KeyValuePair<Key, Value> {
    public private(set) var key: Key
    public private(set) var value: Value
}

extension KeyValuePair: IReasonTemplate where Key == UUID, Value == FRDReasonTemplate {
    var id: UUID {
        return self.key
    }
    
    var reasonMessage: String {
        return self.value.reasonMessage
    }
    
    var amount: FRDAmount {
        return self.value.amount
    }
    
    var importance: FRDImportance {
        return self.value.importance
    }
}

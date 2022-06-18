//
//  FFNewTestClubCall.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation
@testable import FirebaseInterface

internal struct FFNewTestClubCall: FFCallable {    
    enum TestClubType: String {
        case `default`
    }
    
    static let functionName: String = "newTestClub"
    public private(set) var clubId: UUID
    public private(set) var testClubType: TestClubType
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.testClubType, for: "testClubType")
    }
}

extension FFNewTestClubCall.TestClubType: FFParameterType {
    var parameter: String {
        return self.rawValue
    }
}

extension FFNewTestClubCall.TestClubType: Decodable {}

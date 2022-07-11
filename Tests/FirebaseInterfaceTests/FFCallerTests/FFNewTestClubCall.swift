//
//  FFNewTestClubCall.swift
//  
//
//  Created by Steven on 17.06.22.
//

import StrafenProjectTypes
@testable import FirebaseInterface

public struct FFNewTestClubCall: FFCallable {
    public enum TestClubType: String {
        case `default`
    }
    
    public static let functionName: String = "newTestClub"
    public private(set) var clubId: Club.ID
    public private(set) var testClubType: TestClubType
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.testClubType, for: "testClubType")
    }
}

extension FFNewTestClubCall.TestClubType: FFParameterType {
    public var parameter: String {
        return self.rawValue
    }
}

extension FFNewTestClubCall.TestClubType: Decodable {}

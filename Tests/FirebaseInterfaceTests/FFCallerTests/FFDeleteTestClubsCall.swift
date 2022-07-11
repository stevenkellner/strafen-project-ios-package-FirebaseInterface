//
//  FFDeleteTestClubsCall.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation
@testable import FirebaseInterface

public struct FFDeleteTestClubsCall: FFCallable {
    
    public static let functionName: String = "deleteTestClubs"
    
    public var parameters: FFParameters {
        return FFParameters()
    }
}

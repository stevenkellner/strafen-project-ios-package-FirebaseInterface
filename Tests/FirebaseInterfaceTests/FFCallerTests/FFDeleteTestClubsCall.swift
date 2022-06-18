//
//  FFDeleteTestClubsCall.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation
@testable import FirebaseInterface

internal struct FFDeleteTestClubsCall: FFCallable {
    
    static let functionName: String = "deleteTestClubs"
    
    var parameters: FFParameters {
        return FFParameters()
    }
}

//
//  FFChangePersonCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Changes a element of person list.
internal struct FFChangePersonCall: FFCallable {
    
    static let functionName: String = "changePerson"
    
    /// Id of the club to change the person.
    private let clubId: UUID
    
    /// Type of the change.
    private let changeType: FFChangeTypeParameter
    
    /// Person to change.
    private let updatablePerson: FFUpdatableParameter<FFDeletableParameter<FFPersonParameter, UUID>>
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatablePerson, for: "updatablePerson")
    }
}

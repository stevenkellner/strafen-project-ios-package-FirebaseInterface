//
//  FFChangePersonCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Changes a element of person list.
public struct FFChangePersonCall: FFCallable {
    
    public static let functionName: String = "changePerson"
    
    /// Id of the club to change the person.
    public private(set) var clubId: Club.ID
    
    /// Type of the change.
    public private(set) var changeType: FFChangeTypeParameter
    
    /// Person to change.
    public private(set) var updatablePerson: FFUpdatableParameter<FFDeletableParameter<FFPersonParameter, Person.ID>>
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatablePerson, for: "updatablePerson")
    }
}

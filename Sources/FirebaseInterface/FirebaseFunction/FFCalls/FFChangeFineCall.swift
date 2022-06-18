//
//  FFChangeFineCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Changes a element of fine list.
internal struct FFChangeFineCall: FFCallable {
    
    static let functionName: String = "changeFine"
    
    /// Id of the club to change the fine.
    private let clubId: UUID
    
    /// Types of a list item change.
    private let changeType: FFChangeTypeParameter
    
    /// Fine to change.
    private let updatableFine: FFUpdatableParameter<FFDeletableParameter<FFFineParameter, UUID>>
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatableFine, for: "updatableFine")
    }
}

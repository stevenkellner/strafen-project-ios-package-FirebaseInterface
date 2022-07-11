//
//  FFChangeFineCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Changes a element of fine list.
public struct FFChangeFineCall: FFCallable {
    
    public static let functionName: String = "changeFine"
    
    /// Id of the club to change the fine.
    public private(set) var clubId: Club.ID
    
    /// Types of a list item change.
    public private(set) var changeType: FFChangeTypeParameter
    
    /// Fine to change.
    public private(set) var updatableFine: FFUpdatableParameter<FFDeletableParameter<FFFineParameter, Fine.ID>>
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatableFine, for: "updatableFine")
    }
}

//
//  FFChangeFinePayedCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Changes payement state of fine with specified fine id.
public struct FFChangeFinePayedCall: FFCallable {
    
    public static let functionName: String = "changeFinePayed"
    
    /// Id of the club to change the payed state.
    public private(set) var clubId: Club.ID
    
    /// Id of fine of the payed state.
    public private(set) var fineId: Fine.ID
    
    /// Payed state to change.
    public private(set) var payedState: FFPayedStateParameter
    
    /// Update properties of associated fine.
    public private(set) var fineUpdateProperties: FFUpdatableParameter<Any>.UpdateProperties
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.fineId, for: "fineId")
        FFParameter(self.payedState, for: "payedState")
        FFParameter(self.fineUpdateProperties, for: "fineUpdateProperties")
    }
}

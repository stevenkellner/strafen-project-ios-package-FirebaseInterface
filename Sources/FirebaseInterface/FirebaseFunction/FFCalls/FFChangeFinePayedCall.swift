//
//  FFChangeFinePayedCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Changes payement state of fine with specified fine id.
internal struct FFChangeFinePayedCall: FFCallable {
    
    static let functionName: String = "changeFinePayed"
    
    /// Id of the club to change the payed state.
    private let clubId: UUID
    
    /// Id of fine of the payed state.
    private let fineId: UUID
    
    /// Payed state to change.
    private let updatablePayedState: FFUpdatableParameter<FFPayedStateParameter>
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.fineId, for: "fineId")
        FFParameter(self.updatablePayedState, for: "updatablePayedState")
    }
}

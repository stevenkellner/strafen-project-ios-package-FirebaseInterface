//
//  FFChangeLatePaymentInterestCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Changes the late payment interest of club with given club id.
internal struct FFChangeLatePaymentInterestCall: FFCallable {
    
    static let functionName: String = "changeLatePaymentInterest"
    
    /// Id of the club to change the late payment interest.
    private let clubId: UUID
    
    /// Type of the change.
    private let changeType: FFChangeTypeParameter
    
    /// Late payment interest to change.
    private let updatableInterest: FFUpdatableParameter<FFDeletableParameter<FFLatePaymentInterestParameter, UUID?>>
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatableInterest, for: "updatableInterest")
    }
}

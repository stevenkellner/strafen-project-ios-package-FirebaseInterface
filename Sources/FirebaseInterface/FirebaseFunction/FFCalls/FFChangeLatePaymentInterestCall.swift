//
//  FFChangeLatePaymentInterestCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation
import StrafenProjectTypes

/// Changes the late payment interest of club with given club id.
public struct FFChangeLatePaymentInterestCall: FFCallable {
    
    public static let functionName: String = "changeLatePaymentInterest"
    
    /// Id of the club to change the late payment interest.
    public private(set) var clubId: Club.ID
    
    /// Type of the change.
    public private(set) var changeType: FFChangeTypeParameter
    
    /// Late payment interest to change.
    public private(set) var updatableInterest: FFUpdatableParameter<FFDeletableParameter<FFLatePaymentInterestParameter, UUID?>>
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatableInterest, for: "updatableInterest")
    }
}

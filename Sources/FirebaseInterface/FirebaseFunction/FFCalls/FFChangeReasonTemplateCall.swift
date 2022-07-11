//
//  FFChangeReasonTemplateCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Changes a element of reason template list.
public struct FFChangeReasonTemplateCall: FFCallable {
    
    public static let functionName: String = "changeReasonTemplate"
    
    /// Id of the club to change the reason.
    public private(set) var clubId: Club.ID
    
    /// Type of the change.
    public private(set) var changeType: FFChangeTypeParameter
    
    /// Reason to change.
    public private(set) var updatableReasonTemplate: FFUpdatableParameter<FFDeletableParameter<FFReasonTemplateParameter, ReasonTemplate.ID>>
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatableReasonTemplate, for: "updatableReasonTemplate")
    }
}

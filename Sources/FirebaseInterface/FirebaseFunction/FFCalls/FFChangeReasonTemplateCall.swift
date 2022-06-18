//
//  FFChangeReasonTemplateCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Changes a element of reason template list.
internal struct FFChangeReasonTemplateCall: FFCallable {
    
    static let functionName: String = "changeReasonTemplate"
    
    /// Id of the club to change the reason.
    public private(set) var clubId: UUID
    
    /// Type of the change.
    public private(set) var changeType: FFChangeTypeParameter
    
    /// Reason to change.
    public private(set) var updatableReasonTemplate: FFUpdatableParameter<FFDeletableParameter<FFReasonTemplateParameter, UUID>>
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.changeType, for: "changeType")
        FFParameter(self.updatableReasonTemplate, for: "updatableReasonTemplate")
    }
}

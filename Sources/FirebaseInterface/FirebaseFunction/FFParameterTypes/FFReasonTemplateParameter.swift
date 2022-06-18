//
//  FFReasonTemplateParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Reason template with id, reason message, amount and importance.
internal struct FFReasonTemplateParameter {
    
    /// Id of the reason.
    public private(set) var id: UUID
    
    /// Message of the reason.
    public private(set) var reasonMessage: String
    
    /// Amount if the reason.
    public private(set) var amount: FFAmountParameter
    
    /// Importance of the reason.
    public private(set) var importance: FFImportanceParameter
}

extension FFReasonTemplateParameter: FFParameterType {
    var parameter: [String: any FFParameterType] {
        return [
            "id": self.id,
            "reasonMessage": self.reasonMessage,
            "amount": self.amount,
            "importance": self.importance
        ]
    }
}

extension FFReasonTemplateParameter: Decodable {}

extension FFReasonTemplateParameter: IReasonTemplate {
    
    /// Initializes reason template with a `IReasonTemplate` protocol.
    /// - Parameter reasonTemplate: `IReasonTemplate` protocol to initialize the reason template.
    public init(_ reasonTemplate: some IReasonTemplate) {
        self.id = reasonTemplate.id
        self.reasonMessage = reasonTemplate.reasonMessage
        self.amount = FFAmountParameter(reasonTemplate.amount)
        self.importance = FFImportanceParameter(reasonTemplate.importance)
    }
}

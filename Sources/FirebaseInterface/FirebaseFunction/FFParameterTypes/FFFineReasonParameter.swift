//
//
// FFFineReasonParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Contains a reason of a fine, either with a template id or custom with reason message, amount and importance.
public enum FFFineReasonParameter {
    
    /// Fine reason with template id.
    case template(reasonTemplateId: ReasonTemplate.ID)
    
    /// Custom fine reason with reason message, amount and importance.
    case custom(reasonMessage: String, amount: FFAmountParameter, importance: FFImportanceParameter)
}

extension FFFineReasonParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        switch self {
        case .template(let reasonTemplateId):
            return [
                "reasonTemplateId": reasonTemplateId
            ]
        case .custom(let reasonMessage, let amount, let importance):
            return [
                "reasonMessage": reasonMessage,
                "amount": amount,
                "importance": importance
            ]
        }
    }
}

extension FFFineReasonParameter: Decodable {
    private enum CodingKeys: CodingKey {
        case reasonTemplateId
        case reasonMessage
        case amount
        case importance
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let reasonTemplateId = try container.decodeIfPresent(ReasonTemplate.ID.self, forKey: .reasonTemplateId) {
            self = .template(reasonTemplateId: reasonTemplateId)
            return
        }
        
        let reasonMessage = try container.decode(String.self, forKey: .reasonMessage)
        let amount = try container.decode(FFAmountParameter.self, forKey: .amount)
        let importance = try container.decode(FFImportanceParameter.self, forKey: .importance)
        self = .custom(reasonMessage: reasonMessage, amount: amount, importance: importance)
    }
}

extension FFFineReasonParameter: IFineReason {
    
    /// Initializes fine reason with a `IFineReason` protocol.
    /// - Parameter fineReason: `IFineReason` protocol to initialize the fine reason
    public init(_ fineReason: some IFineReason) {
        switch fineReason.concreteFineReason {
        case .template(reasonTemplateId: let reasonTemplateId):
            self = .template(reasonTemplateId: reasonTemplateId)
        case .custom(reasonMessage: let reasonMessage, amount: let amount, importance: let importance):
            self = .custom(reasonMessage: reasonMessage, amount: FFAmountParameter(amount), importance: FFImportanceParameter(importance))
        }
    }
    
    public var concreteFineReason: FineReason {
        switch self {
        case .template(reasonTemplateId: let reasonTemplateId):
            return .template(reasonTemplateId: reasonTemplateId)
        case .custom(reasonMessage: let reasonMessage, amount: let amount, importance: let importance):
            return .custom(reasonMessage: reasonMessage, amount: Amount(amount), importance: Importance(importance))
        }
    }
}

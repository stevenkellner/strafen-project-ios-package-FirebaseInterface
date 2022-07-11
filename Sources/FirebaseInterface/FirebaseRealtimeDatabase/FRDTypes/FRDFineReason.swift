//
//  FRDFineReason.swift
//  
//
//  Created by Steven on 17.06.22.
//

import StrafenProjectTypes

/// Contains a reason of a fine, either with a template id or custom with reason message, amount and importance in realtime database.
public enum FRDFineReason {
    
    /// Fine reason with template id.
    case template(reasonTemplateId: ReasonTemplate.ID)
    
    /// Custom fine reason with reason message, amount and importance.
    case custom(reasonMessage: String, amount: FRDAmount, importance: FRDImportance)
}

extension FRDFineReason: Decodable {
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
        let amount = try container.decode(FRDAmount.self, forKey: .amount)
        let importance = try container.decode(FRDImportance.self, forKey: .importance)
        self = .custom(reasonMessage: reasonMessage, amount: amount, importance: importance)
    }
}

extension FRDFineReason: IFineReason {
    
    /// Initializes fine reason with a `IFineReason` protocol.
    /// - Parameter fineReason: `IFineReason` protocol to initialize the fine reason
    public init(_ fineReason: some IFineReason) {
        switch fineReason.concreteFineReason {
        case .template(reasonTemplateId: let reasonTemplateId):
            self = .template(reasonTemplateId: reasonTemplateId)
        case .custom(reasonMessage: let reasonMessage, amount: let amount, importance: let importance):
            self = .custom(reasonMessage: reasonMessage, amount: FRDAmount(amount), importance: FRDImportance(importance))
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

//
//  FRDFineReason.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation

/// Contains a reason of a fine, either with a template id or custom with reason message, amount and importance in realtime database.
internal enum FRDFineReason {
    
    /// Fine reason with template id.
    case template(reasonTemplateId: UUID)
    
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let reasonTemplateId = try container.decodeIfPresent(UUID.self, forKey: .reasonTemplateId) {
            self = .template(reasonTemplateId: reasonTemplateId)
            return
        }
        
        let reasonMessage = try container.decode(String.self, forKey: .reasonMessage)
        let amount = try container.decode(FRDAmount.self, forKey: .amount)
        let importance = try container.decode(FRDImportance.self, forKey: .importance)
        self = .custom(reasonMessage: reasonMessage, amount: amount, importance: importance)
    }
}

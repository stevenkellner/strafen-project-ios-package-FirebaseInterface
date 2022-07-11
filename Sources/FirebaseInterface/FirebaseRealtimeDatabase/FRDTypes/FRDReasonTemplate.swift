//
//  FRDReasonTemplate.swift
//  
//
//  Created by Steven on 17.06.22.
//

import StrafenProjectTypes

/// Reason template in firebase realtime database.
public struct FRDReasonTemplate {
        
    /// Message of the reason.
    public private(set) var reasonMessage: String
    
    /// Amount of the reason
    public private(set) var amount: FRDAmount
    
    /// Importance of the reason.
    public private(set) var importance: FRDImportance
}

extension FRDReasonTemplate: Decodable {}
 
extension FRDReasonTemplate {
    
    /// Initializes reason template with a `IReasonTemplate` protocol.
    /// - Parameter reasonTemplate: `IReasonTemplate` protocol to initialize the reason template.
    public init(_ reasonTemplate: some IReasonTemplate) {
        self.reasonMessage = reasonTemplate.reasonMessage
        self.amount = FRDAmount(reasonTemplate.amount)
        self.importance = FRDImportance(reasonTemplate.importance)
    }
}

extension KeyValuePair: IReasonTemplate where Key == ReasonTemplate.ID, Value == FRDReasonTemplate {
    
    /// Initializes reason template with a `IReasonTemplate` protocol.
    /// - Parameter reasonTemplate: `IReasonTemplate` protocol to initialize the reason template.
    public init(_ reasonTemplate: some IReasonTemplate) {
        self.init(key: reasonTemplate.id, value: FRDReasonTemplate(reasonTemplate))
    }
    
    public var id: ReasonTemplate.ID {
        return self.key
    }
    
    public var reasonMessage: String {
        return self.value.reasonMessage
    }
    
    public var amount: FRDAmount {
        return self.value.amount
    }
    
    public var importance: FRDImportance {
        return self.value.importance
    }
}

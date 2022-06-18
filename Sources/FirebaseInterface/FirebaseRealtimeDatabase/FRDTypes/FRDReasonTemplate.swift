//
//  FRDReasonTemplate.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation

/// Reason template in firebase realtime database.
internal struct FRDReasonTemplate {
        
    /// Message of the reason.
    public private(set) var reasonMessage: String
    
    /// Amount of the reason
    public private(set) var amount: FRDAmount
    
    /// Importance of the reason.
    public private(set) var importance: FRDImportance
}

extension FFReasonTemplateParameter: Decodable {}
 

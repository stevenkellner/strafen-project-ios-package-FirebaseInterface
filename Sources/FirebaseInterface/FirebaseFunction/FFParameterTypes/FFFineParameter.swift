//
//  FFFineParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Contains all properties of a fine.
internal struct FFFineParameter {
    
    /// Id of the fine.
    public private(set) var id: UUID
    
    /// Associated person id of the fine.
    public private(set) var personId: UUID
    
    /// Payed state of the fine.
    public private(set) var payedState: FFUpdatableParameter<FFPayedStateParameter>
    
    /// Number of the fine.
    public private(set) var number: Int
    
    /// Date of the fine.
    public private(set) var date: Date
    
    /// Fine reason of the fine.
    public private(set) var fineReason: FFFineReasonParameter
}

extension FFFineParameter: FFParameterType {
    var parameter: [String: any FFParameterType] {
        return [
            "id": self.id.parameter,
            "personId": self.personId,
            "payedState": self.payedState,
            "number": self.number,
            "date": self.date,
            "fineReason": self.fineReason
        ]
    }
}

extension FFFineParameter: Decodable {}

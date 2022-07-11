//
//  FFFineParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation
import StrafenProjectTypes

/// Contains all properties of a fine.
public struct FFFineParameter {
    
    /// Id of the fine.
    public private(set) var id: Fine.ID
    
    /// Associated person id of the fine.
    public private(set) var personId: Person.ID
    
    /// Payed state of the fine.
    public private(set) var payedState: FFPayedStateParameter
    
    /// Number of the fine.
    public private(set) var number: UInt
    
    /// Date of the fine.
    public private(set) var date: Date
    
    /// Fine reason of the fine.
    public private(set) var fineReason: FFFineReasonParameter
}

extension FFFineParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
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

extension FFFineParameter: IFine {
    
    /// Initializes fine with a `IFine` protocol.
    /// - Parameter fine: `IFine` protocol to initialize the fine
    public init(_ fine: some IFine) {
        self.id = fine.id
        self.personId = fine.personId
        self.payedState = FFPayedStateParameter(fine.payedState)
        self.number = fine.number
        self.date = fine.date
        self.fineReason = FFFineReasonParameter(fine.fineReason)
    }
}

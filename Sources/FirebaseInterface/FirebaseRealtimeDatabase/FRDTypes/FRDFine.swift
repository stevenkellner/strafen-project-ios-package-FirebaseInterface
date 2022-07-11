//
//  FRDFine.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation
import StrafenProjectTypes

/// Contains all properties of a fine in firebase realtime database.
public struct FRDFine {
        
    /// Associated person id of the fine.
    public private(set) var personId: Person.ID
    
    /// Payed state of the fine.
    public private(set) var payedState: FRDPayedState
    
    /// Number of the fine.
    public private(set) var number: UInt
    
    /// Date of the fine.
    public private(set) var date: Date
    
    /// Fine reason of the fine.
    public private(set) var fineReason: FRDFineReason
}

extension FRDFine: Decodable {}

extension FRDFine {
    
    /// Initializes fine with a `IFine` protocol.
    /// - Parameter fine: `IFine` protocol to initialize the fine
    public init(_ fine: some IFine) {
        self.personId = fine.personId
        self.payedState = FRDPayedState(fine.payedState)
        self.number = fine.number
        self.date = fine.date
        self.fineReason = FRDFineReason(fine.fineReason)
    }
}

extension KeyValuePair: IFine where Key == Fine.ID, Value == FRDFine {
    
    /// Initializes fine with a `IFine` protocol.
    /// - Parameter fine: `IFine` protocol to initialize the fine.
    public init(_ fine: some IFine) {
        self.init(key: fine.id, value: FRDFine(fine))
    }
    
    public var id: Fine.ID {
        return self.key
    }
    
    public var personId: Person.ID {
        return self.value.personId
    }
    
    public var payedState: FRDPayedState {
        return self.value.payedState
    }
    
    public var number: UInt {
        return self.value.number
    }
    
    public var date: Date {
        return self.value.date
    }
    
    public var fineReason: FRDFineReason {
        return self.value.fineReason
    }
}

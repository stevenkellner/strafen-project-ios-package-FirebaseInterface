//
//  FRDFine.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation

/// Contains all properties of a fine in firebase realtime database.
internal struct FRDFine {
    
    /// Id of the fine.
    public private(set) var id: UUID
    
    /// Associated person id of the fine.
    public private(set) var personId: UUID
    
    /// Payed state of the fine.
    public private(set) var payedState: FRDPayedState
    
    /// Number of the fine.
    public private(set) var number: Int
    
    /// Date of the fine.
    public private(set) var date: Date
    
    /// Fine reason of the fine.
    public private(set) var fineReason: FRDFineReason
}

extension FRDFine: Decodable {}

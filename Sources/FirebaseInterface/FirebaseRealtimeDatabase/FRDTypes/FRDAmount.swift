//
//  FRDAmount.swift
//  
//
//  Created by Steven on 17.06.22.
//

import StrafenProjectTypes

/// Amount in firebase realtime database.
public struct FRDAmount {
    
    /// Value of the amount
    public private(set) var value: UInt
    
    /// Value of the sub unit of the amount
    @Clamping(0...99) public private(set) var subUnitValue: UInt = .zero
}

extension FRDAmount: Decodable {
    private init(fromDouble value: Double) {
        self.value = UInt(value)
        self.subUnitValue = UInt(value * 100) - self.value * 100
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawAmount = try container.decode(Double.self)
        
        guard rawAmount >= 0 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Amount is negative.")
        }
        
        self.init(fromDouble: rawAmount)
    }
}

extension FRDAmount: IAmount {
    
    /// Initializes amount with a `IAmount` protocol.
    /// - Parameter amount: `IAmount` protocol to initialize the amount.
    public init(_ amount: some IAmount) {
        self.value = amount.value
        self.subUnitValue = amount.subUnitValue
    }
}

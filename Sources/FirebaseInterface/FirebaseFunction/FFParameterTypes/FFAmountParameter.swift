//
//  FFAmountParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Stores an amount value
public struct FFAmountParameter {
    
    /// Value of the amount
    public private(set) var value: UInt
    
    /// Value of the sub unit of the amount
    @Clamping(0...99) public private(set) var subUnitValue: UInt = .zero
}

extension FFAmountParameter: FFParameterType {
    public var parameter: Double {
        return Double(self.value) + Double(self.subUnitValue) / 100
    }
}

extension FFAmountParameter: Decodable {
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

extension FFAmountParameter: IAmount {
        
    /// Initializes amount with a `IAmount` protocol.
    /// - Parameter amount: `IAmount` protocol to initialize the amount.
    public init(_ amount: some IAmount) {
        self.value = amount.value
        self.subUnitValue = amount.subUnitValue
    }
}

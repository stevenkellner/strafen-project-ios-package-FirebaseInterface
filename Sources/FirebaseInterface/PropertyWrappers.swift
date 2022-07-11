//
//  PropertyWrappers.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Used to clamp a comparable value between lower and upper bound.
@propertyWrapper
public struct Clamping<Value> where Value: Comparable {
    
    /// Clamped raw value.
    private var value: Value
    
    /// Range to be clamped.
    private let range: ClosedRange<Value>
    
    /// Initialized with raw value and range
    /// - Parameters:
    ///   - value: Value to clamp between range
    ///   - range: Range to clamp value between
    public init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        self.value = range.clamp(value)
        self.range = range
    }
    
    public var wrappedValue: Value {
        get { value }
        set { value = range.clamp(newValue) }
    }
}

extension ClosedRange {
    
    /// Clamps value between lower and upper bound
    /// - Parameter value: Clamped value between lower and upper bound
    /// - Returns: Clamped value.
    public func clamp(_ value: Bound) -> Bound {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}

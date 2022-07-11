//
//  Observers.swift
//  
//
//  Created by Steven on 06.07.22.
//

import Foundation

/// Observers that will be called when a new value is received.
internal struct Observers<T> {

    /// Observers that will be called when a new value is received.
    private var observers: [(T) -> Void]

    /// Initializes with no observers.
    public init() {
        self.observers = []
    }

    /// Add a new observer to listen when a new value is received.
    /// - Parameter observer: Observer to listen when a new value is received.
    public mutating func addObserver(_ observer: @escaping (T) -> Void) {
        self.observers.append(observer)
    }

    /// Receive a new value and call all observers.
    /// - Parameter value: Value to receive.
    public func receive(value: T) {
        for observer in self.observers {
            observer(value)
        }
    }
}

//
//  KeyValuePair.swift
//  
//
//  Created by Steven on 18.06.22.
//

import Foundation
import StrafenProjectTypes

/// Contains a pair of a key and the associated value.
public struct KeyValuePair<Key, Value> {
    
    /// Key of the key-value pair.
    public private(set) var key: Key
    
    /// Value of the key-value pair.
    public private(set) var value: Value
    
    /// Map key with specified transform closure.
    /// - Parameter transform: Closure to map key.
    /// - Returns: Key-value pair with mapped key.
    public func mapKey<NewKey>(_ transform: (Key) throws -> NewKey) rethrows -> KeyValuePair<NewKey, Value> {
        return KeyValuePair<NewKey, Value>(key: try transform(self.key), value: self.value)
    }
    
    /// Map value with specified transform closure.
    /// - Parameter transform: Closure to map value.
    /// - Returns: Key-value pair with mapped value.
    public func mapValue<NewValue>(_ transform: (Value) throws -> NewValue) rethrows -> KeyValuePair<Key, NewValue> {
        return KeyValuePair<Key, NewValue>(key: self.key, value: try transform(self.value))
    }
}

extension KeyValuePair: Identifiable where Key: Hashable {
    public var id: Key { return self.key }
}

extension Dictionary {
    
    /// Creates a new dictionary from the key-value pairs in the given sequence, using a combining closure to determine the value for any duplicate keys.
    /// - Parameters:
    ///   - keyValues: A sequence of key-value pairs to use for the new dictionary.
    ///   - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
    public init(_ keyValues: some Sequence<KeyValuePair<Key, Value>>, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try self.init(keyValues.map { (key: $0.key, value: $0.value) }, uniquingKeysWith: combine)
    }
    
    /// Creates a new dictionary from the key-value pairs in the given sequence, replacing the value for any duplicate keys.
    /// - Parameter keyValues: A sequence of key-value pairs to use for the new dictionary.
    public init(_ keyValues: some Sequence<KeyValuePair<Key, Value>>) {
        self.init(keyValues) { _, value in value }
    }
    
    /// An array of key-value pairs.
    public var keyValues: [KeyValuePair<Key, Value>] {
        self.map { KeyValuePair(key: $0.key, value: $0.value) }
    }
}

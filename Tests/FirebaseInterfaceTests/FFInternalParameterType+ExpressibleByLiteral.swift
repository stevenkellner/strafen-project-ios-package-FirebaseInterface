//
//  FFInternalParameterType+ExpressibleByLiteral.swift
//  
//
//  Created by Steven on 02.07.22.
//

import Foundation
@testable import FirebaseInterface

extension FFInternalParameterType: Equatable {
    public static func ==(lhs: FFInternalParameterType, rhs: FFInternalParameterType) -> Bool {
        switch (lhs, rhs) {
        case (.bool(let lhsValue), .bool(let rhsValue)):
            return lhsValue == rhsValue
        case (.int(let lhsValue), .int(let rhsValue)):
            return lhsValue == rhsValue
        case (.uint(let lhsValue), .uint(let rhsValue)):
            return lhsValue == rhsValue
        case (.double(let lhsValue), .double(let rhsValue)):
            return lhsValue == rhsValue
        case (.float(let lhsValue), .float(let rhsValue)):
            return lhsValue == rhsValue
        case (.string(let lhsValue), .string(let rhsValue)):
            return lhsValue == rhsValue
        case (.optional(let lhsValue), .optional(let rhsValue)):
            return lhsValue == rhsValue
        case (.array(let lhsValue), .array(let rhsValue)):
            return lhsValue == rhsValue
        case (.dictionary(let lhsValue), .dictionary(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension FFInternalParameterType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bool(let value):
            return String(describing: value)
        case .int(let value):
            return String(describing: value)
        case .uint(let value):
            return String(describing: value)
        case .double(let value):
            return String(describing: value)
        case .float(let value):
            return String(describing: value)
        case .string(let value):
            return String(describing: value)
        case .optional(let value):
            return String(describing: value.map { String(describing: $0) })
        case .array(let value):
            return String(describing: value.map { String(describing: $0) })
        case .dictionary(let value):
            return String(describing: value.mapValues { String(describing: $0) })
        }
    }
}

extension FFInternalParameterType: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension FFInternalParameterType: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension FFInternalParameterType: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension FFInternalParameterType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension FFInternalParameterType: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .optional(nil)
    }
}

extension FFInternalParameterType: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: FFInternalParameterType...) {
        self = .array(elements)
    }
}

extension FFInternalParameterType: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, FFInternalParameterType)...) {
        self = .dictionary(Dictionary(elements) { _, value in value })
    }
}

//
//  FFParameters.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation
import StrafenProjectTypes

/// Contains parameters for a firebase function call.
public struct FFParameters {
    
    /// Dictionary with key and associated parameter.
    public private(set) var parameters: [String: FFInternalParameterType]
    
    /// Initializes empty function parameters.
    public init() {
        self.parameters = [:]
    }
    
    /// Initializes function parameters with specified parameters.
    /// - Parameter parameters: Parameters for a firebase function call.
    public init(_ parameters: [String: any FFParameterType]) {
        self.parameters = parameters.mapValues(\.internalParameter)
    }
    
    /// Initializes function parameters with specified parameters.
    /// - Parameter parameters: Parameters for a firebase function call.
    public init(_ parameters: [String: FFInternalParameterType]) {
        self.parameters = parameters
    }
    
    /// Parameters valid for firebase function call.
    public var functionParameters: [String: Any] {
        return self.parameters.mapValues(\.functionParameters)
    }
    
    /// Appends parameter with specified key or updates parameter if key already exists.
    /// - Parameters:
    ///   - parameter: Parameter to append to the function parameters.
    ///   - key: Key of the parameter to append.
    public mutating func append(_ parameter: some FFParameterType, for key: String) {
        self.parameters[key] = parameter.internalParameter
    }
    
    /// Appends all parameters or updates if key already exists.
    /// - Parameter parameters: Parameters to append to the function parameters.
    public mutating func append(contentsOf parameters: some Sequence<(key: String, value: any FFParameterType)>) {
        for (key, parameter) in parameters {
            self.append(parameter, for: key)
        }
    }
    
    /// Removes parameter with specified key.
    /// - Parameter key: Key of the parameter to remove.
    public mutating func remove(with key: String) {
        self.parameters.removeValue(forKey: key)
    }
    
    /// Gets parameter with specified key or nil if no parameter with specified key exists.
    /// - Parameter key: Key of parameter to get
    /// - Returns: Parameter with specified key or nil if no parameter with specified key exists.
    public mutating func get(with key: String) -> (FFInternalParameterType)? {
        return self.parameters[key]
    }
    
    /// Gets or sets parameter with specified key or nil for removing parameter.
    /// - Parameter key: Key of parameter to get or set.
    /// - Returns: Parameter with specified key or nil if no parameter with specified key exists.
    public subscript(_ key: String) -> (FFInternalParameterType)? {
        get {
            return self.parameters[key]
        }
        set {
            self.parameters[key] = newValue
        }
    }
}

extension FFParameters: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.parameters)
    }
}

/// Contains a firebaes function parameter and the associated key.
public struct FFParameter {
    
    /// Key of the function parameter.
    public let key: String
    
    /// Firebase function parameter
    public let parameter: FFInternalParameterType
    
    /// Constructs function parameter with associated key
    /// - Parameters:
    ///   - parameter: Firebase function parameter
    ///   - key: Key of the function parameter.
    public init(_ parameter: FFInternalParameterType, for key: String) {
        self.parameter = parameter
        self.key = key
    }
    
    /// Constructs function parameter with associated key
    /// - Parameters:
    ///   - parameter: Firebase function parameter
    ///   - key: Key of the function parameter.
    public init<Parameter>(_ parameter: Parameter, for key: String) where Parameter: FFParameterType {
        self.parameter = parameter.internalParameter
        self.key = key
    }
    
    public init(_ parameters: FFParameters, for key: String) {
        self.parameter = .dictionary(parameters.parameters)
        self.key = key
    }
}

/// Builds firebase function parameters
@resultBuilder
public struct FFParametersBuilder {
    typealias Component = [String: FFInternalParameterType]
    typealias FinalResult = FFParameters
    
    static func buildFinalResult(_ component: Component) -> FinalResult {
        return FFParameters(component)
    }
    
    static func buildExpression(_ expression: FFParameter) -> Component {
        return [expression.key: expression.parameter]
    }
    
    static func buildExpression(_ expression: FFParameters) -> Component {
        return expression.parameters
    }
    
    static func buildBlock(_ components: Component...) -> Component {
        return components.reduce(into: [:]) { partialResult, component in
            partialResult.merge(component) { _, value in value }
        }
    }
    
    static func buildArray(_ components: [Component]) -> Component {
        return components.reduce(into: [:]) { partialResult, component in
            partialResult.merge(component) { _, value in value }
        }
    }
    
    static func buildOptional(_ component: Component?) -> Component {
        return component ?? [:]
    }
    
    static func buildEither(first component: Component) -> Component {
        return component
    }
    
    static func buildEither(second component: Component) -> Component {
        return component
    }
}

/// Contains a valid value as parameter for a firebase function call.
public indirect enum FFInternalParameterType {
    
    /// Contains a `Bool` value.
    case bool(Bool)
    
    /// Contains a `Int` value.
    case int(Int)
    
    /// Contains a `UInt` value.
    case uint(UInt)
    
    /// Contains a `Double` value.
    case double(Double)
    
    /// Contains a `Float` value.
    case float(Float)
    
    /// Contains a `String` value.
    case string(String)
    
    /// Contains a `Optional` value.
    case optional(Optional<FFInternalParameterType>)
    
    /// Contains a `Array` value.
    case array(Array<FFInternalParameterType>)
    
    /// Contains a `Dictionary` value.
    case dictionary(Dictionary<String, FFInternalParameterType>)
    
    /// Parameter valid for firebase function call.
    public var functionParameters: Any {
        switch self {
        case .bool(let value):
            return value
        case .int(let value):
            return value
        case .uint(let value):
            return value
        case .double(let value):
            return value
        case .float(let value):
            return value
        case .string(let value):
            return value
        case .optional(let value):
            return value.map(\.functionParameters) as Any
        case .array(let value):
            return value.map(\.functionParameters)
        case .dictionary(let value):
            return value.mapValues(\.functionParameters)
        }
    }
}

extension FFInternalParameterType: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .uint(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .float(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .optional(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}

/// Type that can be used as firebase function parameter.
public protocol FFParameterType<Parameter> {
    
    /// Parameter for a function call.
    associatedtype Parameter: FFParameterType
    
    /// Parameter for a function call.
    var parameter: Parameter { get }
    
    /// Valid value as parameter for a firebase function call.
    var internalParameter: FFInternalParameterType { get }
}

extension FFParameterType {
    public var internalParameter: FFInternalParameterType {
        return self.parameter.internalParameter
    }
}

extension Bool: FFParameterType {
    public var internalParameter: FFInternalParameterType { .bool(self) }
    public var parameter: Self { self }
}

extension Int: FFParameterType {
    public var internalParameter: FFInternalParameterType { .int(self) }
    public var parameter: Self { self }
}

extension UInt: FFParameterType {
    public var internalParameter: FFInternalParameterType { .uint(self) }
    public var parameter: Self { self }
}

extension Double: FFParameterType {
    public var internalParameter: FFInternalParameterType { .double(self) }
    public var parameter: Self { self }
}

extension Float: FFParameterType {
    public var internalParameter: FFInternalParameterType { .float(self) }
    public var parameter: Self { self }
}

extension String: FFParameterType {
    public var internalParameter: FFInternalParameterType { .string(self) }
    public var parameter: Self { self }
}

extension Optional: FFParameterType where Wrapped: FFParameterType {
    public var internalParameter: FFInternalParameterType { .optional(self.map(\.internalParameter)) }
    public var parameter: Self { self }
}

extension Array: FFParameterType where Element == any FFParameterType {
    public var internalParameter: FFInternalParameterType { .array(self.map(\.internalParameter)) }
    public var parameter: Self { self }
}

extension Dictionary: FFParameterType where Key == String, Value == any FFParameterType {
    public var internalParameter: FFInternalParameterType { .dictionary(self.mapValues(\.internalParameter)) }
    public var parameter: Self { self }
}

extension UUID: FFParameterType {
    public var parameter: String {
        return self.uuidString
    }
}

extension Date: FFParameterType {
    public var parameter: String {
        self.ISO8601Format(.iso8601)
    }
}

extension Tagged: FFParameterType where RawValue: FFParameterType {
    public var parameter: RawValue {
        return self.rawValue
    }
}

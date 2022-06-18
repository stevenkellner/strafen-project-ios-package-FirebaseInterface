//
//  FFParameters.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Contains parameters for a firebase function call.
internal struct FFParameters {
    
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

/// Contains a firebaes function parameter and the associated key.
internal struct FFParameter<Parameter> where Parameter: FFParameterType {
    
    /// Key of the function parameter.
    public let key: String
    
    /// Firebase function parameter
    public let parameter: Parameter
    
    /// Constructs function parameter with associated key
    /// - Parameters:
    ///   - parameter: Firebase function parameter
    ///   - key: Key of the function parameter.
    init(_ parameter: Parameter, for key: String) {
        self.parameter = parameter
        self.key = key
    }
}

/// Builds firebase function parameters
@resultBuilder
internal struct FFParametersBuilder {
    typealias Expression = FFParameter
    typealias Component = [String: any FFParameterType]
    typealias FinalResult = FFParameters
    
    static func buildFinalResult(_ component: Component) -> FinalResult {
        return FFParameters(component)
    }
    
    static func buildExpression(_ expression: Expression<some FFParameterType>) -> Component {
        return [expression.key: expression.parameter]
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
internal indirect enum FFInternalParameterType {
    
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
    
    /// Converts parameter to a firebase function parameter.
    public var firebaseFunctionParameter: Any {
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
            return value.map(\.firebaseFunctionParameter) as Any
        case .array(let value):
            return value.map(\.firebaseFunctionParameter)
        case .dictionary(let value):
            return value.mapValues(\.firebaseFunctionParameter)
        }
    }
}

/// Type that can be used as firebase function parameter.
internal protocol FFParameterType<Parameter> {
    
    /// Parameter for a function call.
    associatedtype Parameter: FFParameterType
    
    /// Parameter for a function call.
    var parameter: Parameter { get }
    
    /// Valid value as parameter for a firebase function call.
    var internalParameter: FFInternalParameterType { get }
}

extension FFParameterType {
    var internalParameter: FFInternalParameterType {
        return self.parameter.internalParameter
    }
}

extension Bool: FFParameterType {
    var internalParameter: FFInternalParameterType { .bool(self) }
    var parameter: Self { self }
}

extension Int: FFParameterType {
    var internalParameter: FFInternalParameterType { .int(self) }
    var parameter: Self { self }
}

extension UInt: FFParameterType {
    var internalParameter: FFInternalParameterType { .uint(self) }
    var parameter: Self { self }
}

extension Double: FFParameterType {
    var internalParameter: FFInternalParameterType { .double(self) }
    var parameter: Self { self }
}

extension Float: FFParameterType {
    var internalParameter: FFInternalParameterType { .float(self) }
    var parameter: Self { self }
}

extension String: FFParameterType {
    var internalParameter: FFInternalParameterType { .string(self) }
    var parameter: Self { self }
}

extension Optional: FFParameterType where Wrapped: FFParameterType {
    var internalParameter: FFInternalParameterType { .optional(self.map(\.internalParameter)) }
    var parameter: Self { self }
}

extension Array: FFParameterType where Element == any FFParameterType {
    var internalParameter: FFInternalParameterType { .array(self.map(\.internalParameter)) }
    var parameter: Self { self }
}

extension Dictionary: FFParameterType where Key == String, Value == any FFParameterType {
    var internalParameter: FFInternalParameterType { .dictionary(self.mapValues(\.internalParameter)) }
    var parameter: Self { self }
}

extension UUID: FFParameterType {
    var parameter: String {
        return self.uuidString
    }
}

extension Date: FFParameterType {
    var parameter: String {
        self.ISO8601Format(.iso8601)
    }
}

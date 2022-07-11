//
//  FFImportanceParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Importance of a fine.
public enum FFImportanceParameter: String {
    
    /// Fine has high importance.
    case high
    
    /// Fine has medium importance.
    case medium
    
    /// Fine has low imporance
    case low
}

extension FFImportanceParameter: FFParameterType {
    public var parameter: String {
        return self.rawValue
    }
}

extension FFImportanceParameter: Decodable {}


extension FFImportanceParameter: IImportance {
    
    /// Initializes importance with a `IImportance` protocol.
    /// - Parameter importance: `IImportance` protocol to initialize the importance.
    public init(_ importance: some IImportance) {
        switch importance.concreteImportance {
        case .high: self = .high
        case .medium: self = .medium
        case .low: self = .low
        }
    }
    
    public var concreteImportance: Importance {
        switch self {
        case .high: return .high
        case .medium: return .medium
        case .low: return .low
        }
    }
}

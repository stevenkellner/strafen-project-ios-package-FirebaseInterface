//
//  FRDImportance.swift
//  
//
//  Created by Steven on 17.06.22.
//

import StrafenProjectTypes

/// Importance of a fine in realtime database.
public enum FRDImportance: String {
    
    /// Fine has high importance.
    case high
    
    /// Fine has medium importance.
    case medium
    
    /// Fine has low imporance
    case low
}

extension FRDImportance: Decodable {}

extension FRDImportance: IImportance {
    
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

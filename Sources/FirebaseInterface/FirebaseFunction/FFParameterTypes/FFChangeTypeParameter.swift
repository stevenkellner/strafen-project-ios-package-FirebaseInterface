//
//  FFChangeTypeParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Types of a list item change.
public enum FFChangeTypeParameter: String {
    
    /// Update or add a list item.
    case update
    
    /// Delete a list item.
    case delete
}

extension FFChangeTypeParameter: FFParameterType {
    public var parameter: String {
        return self.rawValue
    }
}

extension FFChangeTypeParameter: Decodable {}

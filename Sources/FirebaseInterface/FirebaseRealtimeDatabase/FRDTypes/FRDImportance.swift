//
//  FRDImportance.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation

/// Importance of a fine in realtime database.
internal enum FRDImportance: String {
    
    /// Fine has high importance.
    case high
    
    /// Fine has medium importance.
    case medium
    
    /// Fine has low imporance
    case low
}

extension FRDImportance: Decodable {}

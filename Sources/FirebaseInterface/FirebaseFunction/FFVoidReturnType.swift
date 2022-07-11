//
//  FFVoidReturnType.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Defines a decodable void return type for firebase function calls.
public struct FFVoidReturnType {}

extension FFVoidReturnType: Decodable {
    public init(from decoder: Decoder) throws {}
}

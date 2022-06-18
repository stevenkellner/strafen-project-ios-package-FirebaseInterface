//
//  FFPersonParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Contains id and name of a person.
internal struct FFPersonParameter {
    
    /// Id of the person.
    public private(set) var id: UUID
    
    /// Name of a person.
    public private(set) var name: FFPersonNameParameter
}

extension FFPersonParameter: FFParameterType {
    var parameter: [String: any FFParameterType] {
        return [
            "id": self.id,
            "name": self.name
        ]
    }
}

extension FFPersonParameter: Decodable {}

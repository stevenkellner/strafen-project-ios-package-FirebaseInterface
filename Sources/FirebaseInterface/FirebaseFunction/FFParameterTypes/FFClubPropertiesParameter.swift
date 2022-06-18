//
//  FFClubPropertiesParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Contains all properties of a club.
struct FFClubPropertiesParameter {
    
    /// Id of the club.
    public private(set) var id: UUID
    
    /// Name of the club.
    public private(set) var name: String
    
    /// Identifier of the club.
    public private(set) var identifier: String
    
    /// Region code of the club.
    public private(set) var regionCode: String
    
    /// Indicates whether in app payment is active.
    public private(set) var inAppPaymentActive: Bool
}

extension FFClubPropertiesParameter: FFParameterType {
    var parameter: [String: any FFParameterType] {
        return [
            "id": self.id,
            "name": self.name,
            "identifier": self.identifier,
            "regionCode": self.regionCode,
            "inAppPaymentActive": self.inAppPaymentActive
        ]
    }
}

extension FFClubPropertiesParameter: Decodable {}

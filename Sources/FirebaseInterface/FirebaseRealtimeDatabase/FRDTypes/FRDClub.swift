//
//  FRDClub.swift
//  
//
//  Created by Steven on 02.07.22.
//

import StrafenProjectTypes

/// Contains propterties of a club in firebase realtime database.
public struct FRDClub {
        
    /// Identifier of the club.
    public private(set) var identifier: String
    
    /// Name of the club.
    public private(set) var name: String
    
    /// Region code of the club.
    public private(set) var regionCode: String
    
    /// Indicates whether in app payment is active.
    public private(set) var inAppPaymentActive: Bool
    
    /// User ids of signed in persons.
    public private(set) var personUserIds: Dictionary<String, Person.ID>
}

extension FRDClub: Decodable {}

extension FRDClub {
    
    /// Initializes club with a `IClub` protocol.
    /// - Parameter club: `IClub` protocol to initialize the club.
    public init(_ club: some IClub) {
        self.identifier = club.identifier
        self.name = club.name
        self.regionCode = club.regionCode
        self.inAppPaymentActive = club.inAppPaymentActive
        self.personUserIds = club.personUserIds
    }
}

extension KeyValuePair: IClub where Key == Club.ID, Value == FRDClub {
    
    /// Initializes club with a `IClub` protocol.
    /// - Parameter club: `IClub` protocol to initialize the club.
    public init(_ club: some IClub) {
        self.init(key: club.id, value: FRDClub(club))
    }
    
    public var id: Club.ID {
        return self.key
    }
    
    public var identifier: String {
        return self.value.identifier
    }
    
    public var name: String {
        return self.value.name
    }
    
    public var regionCode: String {
        return self.value.regionCode
    }
    
    public var inAppPaymentActive: Bool {
        return self.value.inAppPaymentActive
    }
    
    public var personUserIds: Dictionary<String, Person.ID> {
        return self.value.personUserIds
    }
}

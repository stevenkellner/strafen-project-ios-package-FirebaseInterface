//
//  FRDPayedState.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Foundation
import StrafenProjectTypes

/// Contains properties if a fine is payed in realtime database.
public enum FRDPayedState {
    
    /// Fine is payed.
    case payed(inApp: Bool, payDate: Date)
    
    /// Fine is unpayed.
    case unpayed
    
    /// Fine is settled.
    case settled
}

extension FRDPayedState: Decodable {
    private enum CodingKeys: CodingKey {
        case state
        case inApp
        case payDate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let state = try container.decode(String.self, forKey: .state)
        
        if state == "payed" {
            let inApp = try container.decode(Bool.self, forKey: .inApp)
            let payDate = try container.decode(Date.self, forKey: .payDate)
            self = .payed(inApp: inApp, payDate: payDate)
            return
        } else if state == "unpayed" {
            self = .unpayed
            return
        } else if state == "settled" {
            self = .settled
            return
        }
        throw DecodingError.dataCorruptedError(forKey: .state, in: container, debugDescription: "Invalid state: \(state)")
    }
}

extension FRDPayedState: IPayedState {
    
    /// Initializes payed state with a `IPayedState` protocol.
    /// - Parameter payedState: `IPayedState` protocol to initialize the payed state
    public init(_ payedState: some IPayedState) {
        switch payedState.concretePayedState {
        case .payed(inApp: let inApp, payDate: let payDate):
            self = .payed(inApp: inApp, payDate: payDate)
        case .unpayed:
            self = .unpayed
        case .settled:
            self = .settled
        }
    }
    
    public var concretePayedState: PayedState {
        switch self {
        case .payed(inApp: let inApp, payDate: let payDate):
            return .payed(inApp: inApp, payDate: payDate)
        case .unpayed:
            return .unpayed
        case .settled:
            return .settled
        }
    }
}

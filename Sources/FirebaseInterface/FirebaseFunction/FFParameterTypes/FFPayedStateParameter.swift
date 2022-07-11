//
//  FFPayedStateParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation
import StrafenProjectTypes

/// Contains properties if a fine is payed.
public enum FFPayedStateParameter {
    
    /// Fine is payed.
    case payed(inApp: Bool, payDate: Date)
    
    /// Fine is unpayed.
    case unpayed
    
    /// Fine is settled.
    case settled
}

extension FFPayedStateParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        switch self {
        case .payed(let inApp, let payDate):
            return [
                "state": "payed",
                "inApp": inApp,
                "payDate": payDate
            ]
        case .unpayed:
            return [
                "state": "unpayed",
            ]
        case .settled:
            return [
                "state": "settled",
            ]
        }
    }
}

extension FFPayedStateParameter: Decodable {
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

extension FFPayedStateParameter: IPayedState {
    
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

//
//  FRDDeletable.swift
//  
//
//  Created by Steven on 06.07.22.
//

import StrafenProjectTypes

/// Deleted database item or underlying database item
public enum FRDDeletable<T> where T: Identifiable {

    /// Underlying database item.
    case item(value: T)

    /// Deleted database item.
    case deleted(with: T.ID)
}

extension FRDDeletable: IDeletable {

    /// Initializes deletable with a `IDeletable` protocol.
    /// - Parameter deletable: `IDeletable` protocol to initialize the deletable.
    public init(_ deletable: some IDeletable<T>) {
        switch deletable.concreteDeletable {
        case .item(value: let value): self = .item(value: value)
        case .deleted(with: let id): self = .deleted(with: id)
        }
    }

    public var concreteDeletable: Deletable<T> {
        switch self {
        case .item(value: let value): return .item(value: value)
        case .deleted(with: let id): return .deleted(with: id)
        }
    }
}

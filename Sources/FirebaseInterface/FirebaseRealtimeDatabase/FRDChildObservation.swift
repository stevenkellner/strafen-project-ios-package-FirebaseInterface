//
//  FRDChildObservation.swift
//  
//
//  Created by Steven on 06.07.22.
//

import FirebaseDatabase
import StrafenProjectTypes

/// Observable to handle observed child of a reference of firebase realtime database.
public struct FRDChildObservation<T> {

    /// Observation of added children.
    private let addedObservation: FRDObservation<T>

    /// Observation of changed children.
    private let changedObservation: FRDObservation<T>

    /// Observation of removed children.
    private let removedObservation: FRDObservation<T>

    private init(addedObservation: FRDObservation<T>, changedObservation: FRDObservation<T>, removedObservation: FRDObservation<T>) {
        self.addedObservation = addedObservation
        self.changedObservation = changedObservation
        self.removedObservation = removedObservation
    }

    /// Stop the observation.
    public func stopObservating() {
        self.addedObservation.stopObservating()
        self.changedObservation.stopObservating()
        self.removedObservation.stopObservating()
    }
}

extension FRDChildObservation {

    /// Type of the child change that is observed.
    public enum ChangeType<T> where T: Identifiable {

        /// New child is added.
        case added(value: T)

        /// A child has changed.
        case changed(value: T)

        /// A child was removed.
        case removed(with: T.ID)
    }
}

extension FRDChildObservation where T: Identifiable {

    /// Adds an observer that listens to data changes.
    /// - Parameter observer: Observer that listens to data changes.
    public func addObserver(_ observer: @escaping (Result<ChangeType<T>, Error>) -> Void) {
        self.addedObservation.addObserver { result in
            observer(result.map { .added(value: $0) })
        }
        self.changedObservation.addObserver { result in
            observer(result.map { .changed(value: $0) })
        }
        self.removedObservation.addObserver { result in
            observer(result.map { .removed(with: $0.id) })
        }
    }
}

extension FRDChildObservation where T: IDeletable {

    /// Adds an observer that listens to data changes.
    /// - Parameter observer: Observer that listens to data changes.
    public func addObserver(_ observer: @escaping (Result<ChangeType<T.T>, Error>) -> Void) {
        self.addedObservation.addObserver { result in
            observer(result.map { deletable in
                switch deletable.concrete {
                case .item(value: let value): return .added(value: value)
                case .deleted(with: let id): return .removed(with: id)
                }
            })
        }
        self.changedObservation.addObserver { result in
            observer(result.map { deletable in
                switch deletable.concrete {
                case .item(value: let value): return .changed(value: value)
                case .deleted(with: let id): return .removed(with: id)
                }
            })
        }
        self.removedObservation.addObserver { result in
            observer(result.map { deletable in
                switch deletable.concrete {
                case .item(value: let value): return .removed(with: value.id)
                case .deleted(with: let id): return .removed(with: id)
                }
            })
        }
    }
}

extension FRDChildObservation where T == DataSnapshot {

    /// Initialize observation with root reference of children observe.
    /// - Parameters:
    ///  - reference: Root reference of children to observe.
    ///  - numberIgnoredObservations: Number of observations that will be initially ignored.
    public init(reference: DatabaseReference, ignore numberIgnoredObservations: UInt) {
        self.addedObservation = reference.observe(event: .childAdded, ignore: numberIgnoredObservations)
        self.changedObservation = reference.observe(event: .childChanged, ignore: 0)
        self.removedObservation = reference.observe(event: .childRemoved, ignore: 0)
    }
}

extension FRDChildObservation {

    /// Returns a new observation, mapping any value using the given transformation.
    /// - Parameter transform: A closure that takes the value of the observation.
    /// - Returns: A Observation instance from the closure.
    public func map<R>(_ transform: @escaping (T) throws -> R) -> FRDChildObservation<R> {
        return FRDChildObservation<R>(
            addedObservation: self.addedObservation.map(transform),
            changedObservation: self.changedObservation.map(transform),
            removedObservation: self.removedObservation.map(transform)
        )
    }

    /// Returns a new observation, mapping any value using the given transformation, if the transformation returns nil, the observerd value won’t be omitted.
    /// - Parameter transform: A closure that takes the value of the observation.
    /// - Returns: A Observation instance from the closure.
    public func compactMap<R>(_ transform: @escaping (T) throws -> R?) -> FRDChildObservation<R> {
        return FRDChildObservation<R>(
            addedObservation: self.addedObservation.compactMap(transform),
            changedObservation: self.changedObservation.compactMap(transform),
            removedObservation: self.removedObservation.compactMap(transform)
        )
    }

    /// Observable to handle observed child of a reference of firebase realtime database.
    /// - Parameter isIncluded: A closure that takes the value of the observation.
    /// - Returns: A Observation instance from the closure.
    public func filter(_ isIncluded: @escaping (T) throws -> Bool) -> FRDChildObservation<T> {
        return FRDChildObservation<T>(
            addedObservation: self.addedObservation.filter(isIncluded),
            changedObservation: self.changedObservation.filter(isIncluded),
            removedObservation: self.removedObservation.filter(isIncluded)
        )
    }
}

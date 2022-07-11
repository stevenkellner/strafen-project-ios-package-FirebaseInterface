//
//  FRDObservation.swift
//  
//
//  Created by Steven on 04.07.22.
//

import FirebaseDatabase

/// Observable to handle observed reference of firebase realtime database.
public class FRDObservation<T> {

    /// Handle of the firebase database observation.
    private var handle: DatabaseHandle?

    /// Reference to the value to observe.
    private var reference: DatabaseReference?

    /// Observers that listen to data changes.
    private var observers: Observers<Result<T, Error>>?

    /// Initializes observation with reference to the value to observe and a closure to get observed value.
    /// - Parameters:
    ///   - reference: Reference to the value to observe.
    ///   - onObserve: A closure to get observed value.
    public init(reference: DatabaseReference?, _ onObserve: (@escaping (Result<T, Error>) -> Void) -> DatabaseHandle?) {
        self.reference = reference
        self.observers = Observers()
        self.handle = onObserve { result in
            self.observers?.receive(value: result)
        }
    }

    /// Add a observer that listens to data changes.
    /// - Parameter observer: Observer that listens to data changes.
    public func addObserver(_ observer: @escaping (Result<T, Error>) -> Void) {
        self.observers?.addObserver(observer)
    }

    /// Stop the observation.
    public func stopObservating() {
        guard let handle = self.handle else { return }
        self.reference?.removeObserver(withHandle: handle)
        self.reference = nil
        self.observers = nil
    }
}

extension FRDObservation {

    /// Returns a new observation, mapping any value using the given transformation.
    /// - Parameter transform: A  closure that takes the value of the observation.
    /// - Returns: A Observation instance from the closure.
    public func map<R>(_ transform: @escaping (T) throws -> R) -> FRDObservation<R> {
        return FRDObservation<R>(reference: self.reference) { observe in
            self.addObserver { result in
                observe(result.mapThrowable(transform))
            }
            return self.handle
        }
    }

    /// Returns a new observation, mapping any value using the given transformation, if the transformation returns nil, the observerd value won't be omitted.
    /// - Parameter transform: A  closure that takes the value of the observation.
    /// - Returns: A Observation instance from the closure.
    public func compactMap<R>(_ transform: @escaping (T) throws -> R?) -> FRDObservation<R> {
        return FRDObservation<R>(reference: self.reference) { observe in
            self.addObserver { result in
                guard let result = result.compactMap(transform) else { return }
                observe(result)
            }
            return self.handle
        }
    }

    /// Returns a new observation, the observed value won't be omitted if the closure returns false.
    /// - Parameter isIncluded: A closure that takes the value of the observation.
    /// - Returns: A Observation instance from the closure.
    public func filter(_ isIncluded: @escaping (T) throws -> Bool) -> FRDObservation<T> {
        return FRDObservation<T>(reference: self.reference) { observe in
            self.addObserver { result in
                guard let result = result.filter(isIncluded) else { return }
                observe(result)
            }
            return self.handle
        }
    }
}

//
//  Utilities.swift
//  
//
//  Created by Steven on 18.06.22.
//

import FirebaseCore
import FirebaseDatabase
import CodableFirebase
import Crypter

extension FirebaseDecoder.DateDecodingStrategy {

    /// Date decoding strategy for iso8601 format with milliseconds.
    public static var iso8601WithMilliseconds: FirebaseDecoder.DateDecodingStrategy {
        guard case .custom(let dateDecoder) = JSONDecoder.DateDecodingStrategy.iso8601WithMilliseconds else {
            fatalError("JSONDecoder.DateDecodingStrategy.iso8601WithMilliseconds isn't a custom date decoding strategy.")
        }
        return .custom(dateDecoder)
    }
}

extension Dictionary {
    
    /// Creates a new dictionary from the key-value pairs in the given sequence, replacing the value for any duplicate keys.
    /// - Parameter keysAndValues: A sequence of key-value pairs to use for the new dictionary.
    public init(_ keysAndValues: some Sequence<(Key, Value)>) {
        self.init(keysAndValues, uniquingKeysWith:  { _, value in value })
    }
    
    /// Returns dictionary with appended value with specified key.
    /// - Parameters:
    ///   - value: Value to append.
    ///   - key: Key of the value to append.
    /// - Returns: Dictionary with appended value with specified key.
    func appending(_ value: Value, for key: Key) -> Dictionary<Key, Value> {
        var dict = self
        dict[key] = value
        return dict
    }
}

extension Array {

    /// Returns array with appended element.
    /// - Parameter newElement: Element to append.
    /// - Returns: Array with appended element.
    func appending(_ newElement: Element) -> [Element] {
        var list = self
        list.append(newElement)
        return list
    }
}

extension Database {
    
    /// <#Description#>
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    static func database(url: URL) -> Database {
        return Database.database(url: url.absoluteString)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - app: <#app description#>
    ///   - url: <#url description#>
    /// - Returns: <#description#>
    static func database(app: FirebaseApp, url: URL) -> Database {
        return Database.database(app: app, url: url.absoluteString)
    }

    /// <#Description#>
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func reference(url: URL) -> DatabaseReference {
        return self.reference(withPath: url.absoluteString)
    }
}

extension DatabaseReference {

    /// Used to listen for data changes at particular location.
    /// - Parameters:
    ///   - eventType: Type of the event to observe
    ///   - numberIgnoredObservations: Number of observations that will be initially ignored.
    /// - Returns: Observable to handle observed reference.
    public func observe(event eventType: DataEventType, ignore numberIgnoredObservations: UInt = 1) -> FRDObservation<DataSnapshot> {
        return FRDObservation<DataSnapshot>(reference: self) { observe in
            var observationsToIgnore = numberIgnoredObservations
            return self.observe(eventType) { dataSnapshot in
                guard observationsToIgnore == 0 else {
                    return observationsToIgnore -= 1
                }
                observe(Result<DataSnapshot, Error>.success(dataSnapshot))
            }
        }
    }

    /// Used to listen to data changes at children of this reference.
    /// - Parameter numberIgnoredObservations: Number of observations that will be initially ignored.
    /// - Returns: Observable to handle observed reference.
    public func observeChildren(ignore numberIgnoredObservations: UInt = 1) -> FRDChildObservation<DataSnapshot> {
        return FRDChildObservation(reference: self, ignore: numberIgnoredObservations)
    }
}

extension Result where Failure == Error {

    /// Returns a new result, mapping any success value using the given transformation or failure if transformation throws.
    /// - Parameter transform: A closure that takes the success value of the instance.
    /// - Returns: A Result instance, either from the closure or the previous .failure.
    public func mapThrowable<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Failure> {
        return self.flatMap { value in
            return Result<NewSuccess, Error> { return try transform(value) }
        }
    }

    /// Returns a new result, mapping any success value using the given transformation, return nil if transform returns nil, or failure if transformation throws.
    /// - Parameter transform: A closure that takes the success value of the instance.
    /// - Returns: A Result instance, either from the closure or the previous .failure.
    public func compactMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess?) -> Result<NewSuccess, Failure>? {
        do {
            guard let value = try transform(try self.get()) else { return nil }
            return Result<NewSuccess, Error>.success(value)
        } catch {
            return Result<NewSuccess, Error>.failure(error)
        }
    }

    /// Returns same result if result is .failure or isIncluded closure returns true, returns nil otherwise.
    /// - Parameter isIncluded: A closure that takes the success value of the instance.
    /// - Returns: Same result or nil if closure returned false.
    public func filter(_ isIncluded: (Success) throws -> Bool) -> Result<Success, Failure>? {
        do {
            let value = try self.get()
            guard try isIncluded(value) else { return nil }
            return Result<Success, Error>.success(value)
        } catch {
            return Result<Success, Error>.failure(error)
        }
    }
}

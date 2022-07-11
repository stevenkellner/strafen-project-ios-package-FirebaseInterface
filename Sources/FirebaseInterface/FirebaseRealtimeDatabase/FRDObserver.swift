//
//  FRDObserver.swift
//  
//
//  Created by Steven on 04.07.22.
//

import Crypter
import FirebaseDatabase
import StrafenProjectTypes
import CodableFirebase

/// Observes data from firebase realtime database.
public struct FRDObserver {

    /// Errors that can occur in a database observe.
    public enum ObserveError: Error {

        /// There exists no data in fetched snapshot.
        case noDataInSnapshot

        /// Cryption keys aren't set for database fetcher
        case noCryptionKeys

        /// Key of a snapshot is no uuid.
        case snapshotKeyNoUUID
    }

    /// Cryption keys for firebase realtime database.
    private var cryptionKeys: Crypter.Keys?

    /// Type of the firebase realtime database.
    private var databaseType: DatabaseType = .default

    /// Shared instance for singelton
    public static let shared = Self()

    /// Private init for singleton
    private init() {}

    /// Crypter to decrypt firebase realtime database.
    private var crypter: Crypter {
        get throws {
            guard let cryptionKeys = self.cryptionKeys else {
                throw ObserveError.noCryptionKeys
            }
            return Crypter(keys: cryptionKeys)
        }
    }

    /// Observes value at specified url in database.
    /// - Parameters:
    ///   - type: Type of the value to observe.
    ///   - relativeUrl: Url relative to database to obserce value from.
    ///   - numberIgnoredObservations: Number of observations that will be initially ignored.
    /// - Returns: Observation used to listen for data changes at particular location.
    public func observe<Value>(_ type: Value.Type, at relativeUrl: URL, ignore numberIgnoredObservations: UInt = 1) -> FRDObservation<KeyValuePair<String, Value>> where Value: Decodable {
        return Database.database(url: self.databaseType.databaseUrl).reference(url: relativeUrl).observe(event: .value, ignore: numberIgnoredObservations).map { snapshot in
            return try self.decode(type, from: snapshot)
        }
    }

    /// Observes children of specified url in database.
    /// - Parameters:
    ///   - type: Type of the value to observe.
    ///   - relativeUrl: Url relative to database to observe children from.
    ///   - numberIgnoredObservations: Number of observations that will be initially ignored.
    /// - Returns: Observation used to listen for data changes at particular location.
    public func observeChildren<Value>(_ type: Value.Type, at relativeUrl: URL, ignore numberIgnoredObservations: UInt = 1) -> FRDChildObservation<KeyValuePair<String, Value>> where Value: Decodable {
        return Database.database(url: self.databaseType.databaseUrl).reference(url: relativeUrl).observeChildren(ignore: numberIgnoredObservations).map { snapshot in
            return try self.decode(type, from: snapshot)
        }
    }

    /// Decodes value from specified snapshot.
    /// - Parameters:
    ///   - type: Type of the value to decode.
    ///   - snapshot: Snapshot to get the data to decode.
    /// - Returns: Key and decoded value.
    private func decode<Value>(_ type: Value.Type, from snapshot: DataSnapshot) throws -> KeyValuePair<String, Value> where Value: Decodable {

        // Check if data exists
        guard snapshot.exists(), let data = snapshot.value else {
            throw ObserveError.noDataInSnapshot
        }

        // Decode value
        let decoder = FirebaseDecoder()
        decoder.dateDecodingStrategy = .iso8601WithMilliseconds
        decoder.dataDecodingStrategy = .base64
        let value = try decoder.decode(Value.self, from: data)

        // Return key and value
        return KeyValuePair(key: snapshot.key, value: value)
    }

    /// Sets the cryption keys for crypter.
    /// - Parameter cryptionKeys: Cryption keys to set in the returned database observer.
    /// - Returns: Database observer with specified cryption keys.
    public func cryptionKeys(_ cryptionKeys: Crypter.Keys) -> FRDObserver {
        var caller = self
        caller.cryptionKeys = cryptionKeys
        return caller
    }

    /// Sets the firebase database type to `testing`.
    public var forTesting: FRDObserver {
        var fetcher = self
        fetcher.databaseType = .testing
        return fetcher
    }
}

extension FRDObserver {

    /// Observes late payment interest of specified club in firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch late payment interest from.
    /// - Returns: Observed late payment interest.
    public func observeLatePaymentInterest(of clubId: Club.ID) -> FRDObservation<LatePaymentInterest?> {
        return self.observe(String.self, at: URL(string: clubId.uuidString)!.appending(path: "latePaymentInterest"), ignore: 1).map { keyValuePair in

            // Decrypt late payment interest
            let decryptedJson = try self.crypter.decryptAesAndVernam(keyValuePair.value.unishortData)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithMilliseconds
            decoder.dataDecodingStrategy = .base64

            // Return nil if element is deleted
            let deleted = try? decoder.decode(FRDDeleted.self, from: decryptedJson)
            guard deleted == nil else { return nil }

            // Return decoded late payment interest
            return LatePaymentInterest(try decoder.decode(FRDLatePaymentInterest.self, from: decryptedJson))
        }
    }

    /// Observes list elements of specified url in database.
    /// - Parameters:
    ///   - clubId: Id of the club to observe elements from.
    ///   - numberIgnoredObservations: Number of observations that will be initially ignored.
    ///   - listPathFromClub: Path to the list from club.
    /// - Returns: Observation used to listen for data changes at particular location.
    private func observeListElements<Element>(of clubId: Club.ID, ignore numberIgnoredObservations: UInt = 1, path listPathFromClub: String) -> FRDChildObservation<Deletable<Element>> where Element: ListElement {
        return self.observeChildren(String.self, at: URL(string: clubId.uuidString)!.appending(path: listPathFromClub), ignore: numberIgnoredObservations).map { keyValuePair in

            // Get id of the element
            guard let rawId = UUID(uuidString: keyValuePair.key), let id = Element.ID(rawValue: rawId) else {
                throw ObserveError.snapshotKeyNoUUID
            }

            // Decrypt element
            let decryptedJson = try self.crypter.decryptAesAndVernam(keyValuePair.value.unishortData)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithMilliseconds
            decoder.dataDecodingStrategy = .base64

            // Return removed if element is deleted
            let deleted = try? decoder.decode(FRDDeleted.self, from: decryptedJson)
            guard deleted == nil else {
                return .deleted(with: id)
            }

            // Decode element
            let decodedFrdElement = try decoder.decode(Element.FRDListElement.self, from: decryptedJson)
            return .item(value: Element(KeyValuePair(key: id, value: decodedFrdElement)))
        }
    }

    /// Observes all< persons in database.
    /// - Parameters:
    ///   - clubId: Id of the club to observe persons from.
    ///   - numberIgnoredObservations: Number of observations that will be initially ignored.
    /// - Returns: Observation used to listen for data changes at particular location.
    public func observePersons(of clubId: Club.ID, ignore numberIgnoredObservations: UInt = 1) -> FRDChildObservation<Deletable<Person>> {
        return self.observeListElements(of: clubId, ignore: numberIgnoredObservations, path: "persons")
    }

    /// Observes all reason templates in database.
    /// - Parameters:
    ///   - clubId: Id of the club to observe reason templates from.
    ///   - numberIgnoredObservations: Number of observations that will be initially ignored.
    /// - Returns: Observation used to listen for data changes at particular location.
    public func observeReasonTemplates(of clubId: Club.ID, ignore numberIgnoredObservations: UInt = 1) -> FRDChildObservation<Deletable<ReasonTemplate>> {
        return self.observeListElements(of: clubId, ignore: numberIgnoredObservations, path: "reasonTemplates")
    }

    /// Observes all fines in database.
    /// - Parameters:
    ///   - clubId: Id of the club to observe fines from.
    ///   - numberIgnoredObservations: Number of observations that will be initially ignored.
    /// - Returns: Observation used to listen for data changes at particular location.
    public func observeFines(of clubId: Club.ID, ignore numberIgnoredObservations: UInt = 1) -> FRDChildObservation<Deletable<Fine>> {
        return self.observeListElements(of: clubId, ignore: numberIgnoredObservations, path: "fines")
    }
}

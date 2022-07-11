//
//  FRDFetcher.swift
//  
//
//  Created by Steven on 17.06.22.
//

import Crypter
import FirebaseDatabase
import CodableFirebase
import StrafenProjectTypes

/// Fetches data from firebase realtime database.
public struct FRDFetcher {
    
    /// Errors that can occur in a database fetch.
    public enum FetchError: Error {
        
        /// There exists no data in fetched snapshot.
        case noDataInSnapshot
        
        /// Child is no data snapshot.
        case childNoSnapshot
        
        /// Key of a snapshot is no uuid.
        case snapshotKeyNoUUID
        
        /// Cryption keys aren't set for database fetcher
        case noCryptionKeys
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
                throw FetchError.noCryptionKeys
            }
            return Crypter(keys: cryptionKeys)
        }
    }
    
    /// Fetches a value from specified url.
    /// - Parameters:
    ///   - type: Type of the value to fetch,
    ///   - relativeUrl: Url relative to database to fetch value from.
    /// - Returns: Fetched key and value.
    public func fetch<Value>(_ type: Value.Type, from relativeUrl: URL) async throws -> KeyValuePair<String, Value> where Value: Decodable {
        let dataSnapshot = try await Database.database(url: self.databaseType.databaseUrl).reference(url: relativeUrl).getData()
        return try self.decode(Value.self, from: dataSnapshot)
    }
    
    /// Fetches children from specified url.
    /// - Parameters:
    ///   - type: Type of the children to fetch.
    ///   - relativeUrl: Url relative to database to fetch children from.
    /// - Returns: Fetched key and value pairs.
    public func fetchChildren<Value>(_ type: Value.Type, from relativeUrl: URL) async throws -> Dictionary<String, Value> where Value: Decodable {
                
        // Fetch data
        let dataSnapshot = try await Database.database(url: self.databaseType.databaseUrl).reference(url: relativeUrl).getData()
        guard dataSnapshot.exists(), dataSnapshot.hasChildren() else {
            throw FetchError.noDataInSnapshot
        }
        
        // Decode values
        let children = try dataSnapshot.children.map { childSnapshot in
            guard let childSnapshot = childSnapshot as? DataSnapshot else {
                throw FetchError.childNoSnapshot
            }
            return try self.decode(Value.self, from: childSnapshot)
        }
        
        // Return children
        return Dictionary(children)
    }

    /// Decodes value from specified snapshot.
    /// - Parameters:
    ///   - type: Type of the value to decode.
    ///   - snapshot: Snapshot to get the data to decode.
    /// - Returns: Key and decoded value.
    private func decode<Value>(_ type: Value.Type, from snapshot: DataSnapshot) throws -> KeyValuePair<String, Value> where Value: Decodable {
        
        // Check if data exists
        guard snapshot.exists(), let data = snapshot.value else {
            throw FetchError.noDataInSnapshot
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
    /// - Parameter cryptionKeys: Cryption keys to set in the returned database fetcher.
    /// - Returns: Database fetcher with specified cryption keys.
    public func cryptionKeys(_ cryptionKeys: Crypter.Keys) -> FRDFetcher {
        var caller = self
        caller.cryptionKeys = cryptionKeys
        return caller
    }
    
    /// Sets the firebase database type to `testing`.
    public var forTesting: FRDFetcher {
        var fetcher = self
        fetcher.databaseType = .testing
        return fetcher
    }
}

extension FRDFetcher {
    
    /// Fetches club properties of specified club from firebase realtime database.
    /// - Parameter id: Id of the club to fetch club properties from.
    /// - Returns: Fetched club properties.
    public func fetchClub(with id: Club.ID) async throws -> Club {
        let databaseClub = try await self.fetch(FRDClub.self, from: URL(string: id.uuidString)!)
        let club = try databaseClub.mapKey { id in
            guard let id = Club.ID(rawValue: UUID(uuidString: id)) else {
                throw FetchError.snapshotKeyNoUUID
            }
            return id
        }
        return Club(club)
    }

    /// Fetches late payment interest of specified club from firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch late payment interest from.
    /// - Returns: Fetched late payment interest.
    public func fetchLatePaymentInterest(of clubId: Club.ID) async throws -> LatePaymentInterest? {

        // Fetch database late payment interest
        let databaseLatePaymentInterest: String
        do {
            databaseLatePaymentInterest = try await self.fetch(String.self, from: URL(string: "\(clubId.uuidString)/latePaymentInterest")!).value
        } catch FetchError.noDataInSnapshot {
            return nil
        }

        // Decrypt late payment interest
        let decryptedJson = try self.crypter.decryptAesAndVernam(databaseLatePaymentInterest.unishortData)
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

extension FRDFetcher {

    /// Fetches all elements of specified club from firebase realtime database
    /// - Parameter clubId: Id of the club to fetch elements from.
    /// - Parameter listPathFromClub: Path to the list from club.
    /// - Returns: Fetched elemets with associated id.
    private func fetchListElements<Element>(of clubId: Club.ID, path listPathFromClub: String) async throws -> Dictionary<Element.ID, Element> where Element: ListElement {

        // Fetch frd elements:
        let frdElements = try await self.fetchChildren(String.self, from: URL(string: clubId.uuidString)!.appending(path: listPathFromClub))

        // Decrypt and decode elements
        let keyValueElements: [KeyValuePair<Element.ID, Element>?] = try frdElements.map { entry in

            // Get id of the element
            guard let rawId = UUID(uuidString: entry.key), let id = Element.ID(rawValue: rawId) else {
                throw FetchError.snapshotKeyNoUUID
            }

            // Decrypt elements
            let decryptedJson = try self.crypter.decryptAesAndVernam(entry.value.unishortData)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithMilliseconds
            decoder.dataDecodingStrategy = .base64

            // Return nil if element is deleted
            let deleted = try? decoder.decode(FRDDeleted.self, from: decryptedJson)
            guard deleted == nil else { return nil }

            // Decode element
            let decodedFrdElement = try decoder.decode(Element.FRDListElement.self, from: decryptedJson)
            let element = Element(KeyValuePair(key: id, value: decodedFrdElement))
            return KeyValuePair(key: id, value: element)
        }

        // Return dictionary of ids and elements
        return Dictionary(keyValueElements.compactMap { $0 })
    }

    /// Fetches all persons of specified club from firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch persons from.
    /// - Returns: Fetched persons with associated id.
    public func fetchPersons(of clubId: Club.ID) async throws -> Dictionary<Person.ID, Person> {
        return try await self.fetchListElements(of: clubId, path: "persons")
    }

    /// Fetches all reason templatess of specified club from firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch reason templates from.
    /// - Returns: Fetched reason templates with associated id.
    public func fetchReasonTemplates(of clubId: Club.ID) async throws -> Dictionary<ReasonTemplate.ID, ReasonTemplate> {
        return try await self.fetchListElements(of: clubId, path: "reasonTemplates")
    }
    
    /// Fetches all fines of specified club from firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch fines from.
    /// - Returns: Fetched fines with associated id.
    public func fetchFines(of clubId: Club.ID) async throws -> Dictionary<Fine.ID, Fine> {
        return try await self.fetchListElements(of: clubId, path: "fines")
    }
}

extension FRDFetcher {

    /// Total and undeleted counts of database lists like persons, reason templates and fines.
    public struct ListCounts: Decodable {

        /// Total count of database list.
        let total: UInt

        /// Undeleted count of database list.
        let undeleted: UInt
    }

    /// Fetches the number of persons at specified club.
    /// - Parameter clubId: Id of the club to fetch persons count from.
    /// - Returns: Number of persons at specified club
    public func fetchPersonsCount(of clubId: Club.ID) async throws -> Person.Count {
        return try await self.fetch(Person.Count.self, from: URL(string: clubId.uuidString)!.appending(path: "listCounts/persons")).value
    }

    /// Fetches the number of reason templates at specified club.
    /// - Parameter clubId: Id of the club to fetch reason templates count from.
    /// - Returns: Number of reason templates at specified club
    public func fetchReasonTemplatesCount(of clubId: Club.ID) async throws -> ReasonTemplate.Count {
        return try await self.fetch(ReasonTemplate.Count.self, from: URL(string: clubId.uuidString)!.appending(path: "listCounts/reasonTemplates")).value
    }

    /// Fetches the number of fines at specified club.
    /// - Parameter clubId: Id of the club to fetch fines count from.
    /// - Returns: Number of fines at specified club
    public func fetchFinesCount(of clubId: Club.ID) async throws -> Fine.Count {
        return try await self.fetch(Fine.Count.self, from: URL(string: clubId.uuidString)!.appending(path: "listCounts/fines")).value
    }
}

extension Person {

    /// Type of the list count of the person.
    public typealias Count = Tagged<(Person, count: ()), FRDFetcher.ListCounts>
}

extension ReasonTemplate {

    /// Type of the list count of the reason template.
    public typealias Count = Tagged<(ReasonTemplate, count: ()), FRDFetcher.ListCounts>
}

extension Fine {

    /// Type of the list count of the fine.
    public typealias Count = Tagged<(Fine, count: ()), FRDFetcher.ListCounts>
}

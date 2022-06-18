//
//  FRDFetcher.swift
//  
//
//  Created by Steven on 17.06.22.
//

import FirebaseDatabase
import CodableFirebase

/// Fetches data from firebase realtime database.
internal struct FRDFetcher {
    
    /// Errors that can occur in a database fetch.
    enum FetchError: Error {
        
        /// There exists no data in fetched snapshot.
        case noDataInSnapshot
        
        /// Child is no data snapshot.
        case childNoSnapshot
    }
    
    /// Type of the firebase realtime database.
    private var databaseType: DatabaseType = .default
    
    /// Shared instance for singelton
    public static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Fetches a value from specified url.
    /// - Parameters:
    ///   - type: Type of the value to fetch,
    ///   - relativeUrl: Url relative to database to fetch value from.
    /// - Returns: Fetched key and value.
    public func fetch<Value>(_ type: Value.Type, from relativeUrl: URL) async throws -> Dictionary<String, Value>.Element where Value: Decodable {
        let dataSnapshot = try await Database.database(url: self.databaseType.databaseUrl.path).reference(fromURL: relativeUrl.path).getData()
        return try self.decode(Value.self, from: dataSnapshot)
    }
    
    /// Fetches children from specified url.
    /// - Parameters:
    ///   - type: Type of the children to fetch.
    ///   - relativeUrl: Url relative to database to fetch children from.
    /// - Returns: Fetched key and value pairs.
    public func fetchChildren<Value>(_ type: Value.Type, from relativeUrl: URL) async throws -> Dictionary<String, Value> where Value: Decodable {
        
        // Fetch data
        let dataSnapshot = try await Database.database(url: self.databaseType.databaseUrl.path).reference(fromURL: relativeUrl.path).getData()
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
        return Dictionary(children) { _, value in value }
    }
    
    /// Decodes value from specified snapshot.
    /// - Parameters:
    ///   - type: Type of the value to decode.
    ///   - snapshot: Snapshot to get the data to decode.
    /// - Returns: Key and decoded value.
    private func decode<Value>(_ type: Value.Type, from snapshot: DataSnapshot) throws -> Dictionary<String, Value>.Element where Value: Decodable {
        
        // Check if data exists
        guard snapshot.exists(), let data = snapshot.value else {
            throw FetchError.noDataInSnapshot
        }
        
        // Decode value
        let decoder = FirebaseDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.dataDecodingStrategy = .base64
        let value = try decoder.decode(Value.self, from: data)
        
        // Return key and value
        return (key: snapshot.key, value: value)
    }
    
    /// Sets the firebase database type to `testing`.
    public var forTesting: FRDFetcher {
        var fetcher = self
        fetcher.databaseType = .testing
        return fetcher
    }
}

extension FRDFetcher {
        
    /// Fetches all persons of specified club from firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch persons from.
    /// - Returns: Fetched persons with associated id.
    public func fetchPersons(of clubId: UUID) async throws -> Dictionary<String, FRDPerson {
        return try await self.fetchChildren(FRDPerson.self, from: URL(string: "\(clubId.uuidString)/persons")!)
    }
    
    /// Fetches all reason templatess of specified club from firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch reason templates from.
    /// - Returns: Fetched reason templates with associated id.
    public func fetchReasonTemplates(of clubId: UUID) async throws -> Dictionary<String, FRDReasonTemplate {
        return try await self.fetchChildren(FRDReasonTemplate.self, from: URL(string: "\(clubId.uuidString)/reasonTemplatess")!)
    }
    
    /// Fetches all fines of specified club from firebase realtime database.
    /// - Parameter clubId: Id of the club to fetch fines from.
    /// - Returns: Fetched fines with associated id.
    public func fetchFines(of clubId: UUID) async throws -> Dictionary<String, FRDFine {
        return try await self.fetchChildren(FRDFine.self, from: URL(string: "\(clubId.uuidString)/fines")!)
    }
}

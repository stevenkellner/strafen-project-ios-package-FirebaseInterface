//
//  DatabaseType.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Type of the database for firebase function calls.
public enum DatabaseType: String {
    
    /// Changes content on the release database.
    case release
    
    /// Changes content on the debug database.
    case debug
    
    /// Changes content on the testing database.
    case testing
    
    /// Url of the realtime database.
    public var databaseUrl: URL {
        switch self {
        case .release:
            return URL(string: "https://strafen-project-default-rtdb.europe-west1.firebasedatabase.app/")!
        case .debug:
            return URL(string: "https://strafen-project-debug.europe-west1.firebasedatabase.app/")!
        case .testing:
            return URL(string: "https://strafen-project-tests.europe-west1.firebasedatabase.app/")!
        }
    }
    
    /// `release` or `debug` depending on the build settings.
    public static var `default`: DatabaseType {
#if DEBUG
        return .debug
#else
        return .release
#endif
    }
}

extension DatabaseType: FFParameterType {
    public var parameter: String {
        return self.rawValue
    }
}

extension DatabaseType: Decodable {}

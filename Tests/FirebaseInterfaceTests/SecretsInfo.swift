//
//  SecretsInfo.swift
//  
//
//  Created by Steven on 02.07.22.
//

import Crypter

struct SecretsInfo: Decodable {
    struct TestUser: Decodable {
        enum CodingKeys: String, CodingKey {
            case email = "EMAIL"
            case password = "PASSWORD"
        }
        
        let email: String
        let password: String
    }
    
    struct PrivateKey: Decodable {
        enum CodingKeys: String, CodingKey {
            case forRelease = "RELEASE"
            case forDebug = "DEBUG"
            case forTesting = "TESTING"
        }
        
        let forRelease: String
        let forDebug: String
        let forTesting: String
    }
    
    struct CryptionKeys: Decodable {
        enum CodingKeys: String, CodingKey {
            case forRelease = "RELEASE"
            case forDebug = "DEBUG"
            case forTesting = "TESTING"
        }
        
        let forRelease: Crypter.Keys
        let forDebug: Crypter.Keys
        let forTesting: Crypter.Keys
    }
    
    enum CodingKeys: String, CodingKey {
        case testUser = "FA_TEST_USER"
        case privateKey = "FF_PRIVATE_KEY"
        case cryptionKeys = "FF_CRYPTION_KEYS"
    }
    
    let testUser: TestUser
    let privateKey: PrivateKey
    let cryptionKeys: CryptionKeys
}

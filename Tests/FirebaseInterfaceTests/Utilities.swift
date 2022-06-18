//
//  Utilities.swift
//  
//
//  Created by Steven on 14.06.22.
//

import FirebaseCore
import FirebaseAuth
@testable import FirebaseInterface

struct FConfigurator {
    
    private var alreadyConfigured = false
    
    /// Shared instance for singelton
    public static var shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    mutating func configure() {
        guard !self.alreadyConfigured else { return }
        self.alreadyConfigured = true
        FirebaseApp.configure()
    }
}

extension FFInternalParameterType: Equatable {
    public static func ==(lhs: FFInternalParameterType, rhs: FFInternalParameterType) -> Bool {
        switch (lhs, rhs) {
        case (.bool(let lhsValue), .bool(let rhsValue)):
            return lhsValue == rhsValue
        case (.int(let lhsValue), .int(let rhsValue)):
            return lhsValue == rhsValue
        case (.uint(let lhsValue), .uint(let rhsValue)):
            return lhsValue == rhsValue
        case (.double(let lhsValue), .double(let rhsValue)):
            return lhsValue == rhsValue
        case (.float(let lhsValue), .float(let rhsValue)):
            return lhsValue == rhsValue
        case (.string(let lhsValue), .string(let rhsValue)):
            return lhsValue == rhsValue
        case (.optional(let lhsValue), .optional(let rhsValue)):
            return lhsValue == rhsValue
        case (.array(let lhsValue), .array(let rhsValue)):
            return lhsValue == rhsValue
        case (.dictionary(let lhsValue), .dictionary(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension FFInternalParameterType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bool(let value):
            return String(describing: value)
        case .int(let value):
            return String(describing: value)
        case .uint(let value):
            return String(describing: value)
        case .double(let value):
            return String(describing: value)
        case .float(let value):
            return String(describing: value)
        case .string(let value):
            return String(describing: value)
        case .optional(let value):
            return String(describing: value.map(\.firebaseFunctionParameter))
        case .array(let value):
            return String(describing: value.map(\.firebaseFunctionParameter))
        case .dictionary(let value):
            return String(describing: value.mapValues(\.firebaseFunctionParameter))
        }
    }
}

extension FFInternalParameterType: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension FFInternalParameterType: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension FFInternalParameterType: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension FFInternalParameterType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension FFInternalParameterType: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .optional(nil)
    }
}

extension FFInternalParameterType: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: FFInternalParameterType...) {
        self = .array(elements)
    }
}

extension FFInternalParameterType: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, FFInternalParameterType)...) {
        self = .dictionary(Dictionary(elements) { _, value in value })
    }
}

extension FFAmountParameter: Equatable {
    public static func ==(lhs: FFAmountParameter, rhs: FFAmountParameter) -> Bool {
        return lhs.value == rhs.value &&
        lhs.subUnitValue == rhs.subUnitValue
    }
}

extension FFClubPropertiesParameter: Equatable {
    public static func ==(lhs: FFClubPropertiesParameter, rhs: FFClubPropertiesParameter) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.identifier == rhs.identifier &&
        lhs.regionCode == rhs.regionCode &&
        lhs.inAppPaymentActive == rhs.inAppPaymentActive
    }
}

extension FFDeletableParameter: Equatable where T: Equatable, ID: Equatable {
    public static func ==(lhs: FFDeletableParameter<T, ID>, rhs: FFDeletableParameter<T, ID>) -> Bool {
        switch (lhs, rhs) {
        case (.deleted(id: let lhsId), .deleted(id: let rhsId)):
            return lhsId == rhsId
        case (.item(let lhsItem), .item(let rhsItem)):
            return lhsItem == rhsItem
        default:
            return false
        }
    }
}

extension FFFineParameter: Equatable {
    public static func ==(lhs: FFFineParameter, rhs: FFFineParameter) -> Bool {
        return lhs.id == rhs.id &&
            lhs.personId == rhs.personId &&
            Calendar.current.isDate(lhs.date, equalTo: rhs.date, toGranularity: .nanosecond) &&
            lhs.fineReason == rhs.fineReason &&
            lhs.number == rhs.number &&
            lhs.payedState == rhs.payedState
    }
}

extension FFFineReasonParameter: Equatable {
    public static func ==(lhs: FFFineReasonParameter, rhs: FFFineReasonParameter) -> Bool {
        switch (lhs, rhs) {
        case (.template(reasonTemplateId: let lhsReasonTemplateId), .template(reasonTemplateId: let rhsReasonTemplateId)):
            return lhsReasonTemplateId == rhsReasonTemplateId
        case (.custom(reasonMessage: let lhsReasonMessage, amount: let lhsAmount, importance: let lhsImportance), .custom(reasonMessage: let rhsReasonMessage, amount: let rhsAmount, importance: let rhsImportance)):
            return lhsReasonMessage == rhsReasonMessage &&
                lhsAmount == rhsAmount &&
                lhsImportance == rhsImportance
        default:
            return false
        }
    }
}

extension FFPayedStateParameter: Equatable {
    public static func ==(lhs: FFPayedStateParameter, rhs: FFPayedStateParameter) -> Bool {
        switch (lhs, rhs) {
        case (.payed(inApp: let lhsInApp, payDate: let lhsPayDate), .payed(inApp: let rhsInApp, payDate: let rhsPayDate)):
            return lhsInApp == rhsInApp &&
                Calendar.current.isDate(lhsPayDate, equalTo: rhsPayDate, toGranularity: .nanosecond)
        case (.unpayed, .unpayed):
            return true
        case (.settled, .settled):
            return true
        default:
            return false
        }
    }
}

extension FFUpdatableParameter.UpdateProperties: Equatable {
    public static func ==(lhs: FFUpdatableParameter.UpdateProperties, rhs: FFUpdatableParameter.UpdateProperties) -> Bool {
        return Calendar.current.isDate(lhs.timestamp, equalTo: rhs.timestamp, toGranularity: .nanosecond) &&
            lhs.personId == rhs.personId
    }
}

extension FFUpdatableParameter: Equatable where T: Equatable {
    public static func ==(lhs: FFUpdatableParameter<T>, rhs: FFUpdatableParameter<T>) -> Bool {
        return lhs.property == rhs.property &&
            lhs.updateProperties == rhs.updateProperties
    }
}

extension FFLatePaymentInterestParameter.TimePeriod: Equatable {
    public static func ==(lhs: FFLatePaymentInterestParameter.TimePeriod, rhs: FFLatePaymentInterestParameter.TimePeriod) -> Bool {
        return lhs.value == rhs.value &&
            lhs.unit == rhs.unit
    }
}

extension FFLatePaymentInterestParameter: Equatable {
    public static func ==(lhs: FFLatePaymentInterestParameter, rhs: FFLatePaymentInterestParameter) -> Bool {
        return lhs.interestFreePeriod == rhs.interestFreePeriod &&
            lhs.interestPeriod == rhs.interestPeriod &&
            lhs.interestRate == rhs.interestRate &&
            lhs.compoundInterest == rhs.compoundInterest
    }
}

extension FFPersonNameParameter: Equatable {
    public static func ==(lhs: FFPersonNameParameter, rhs: FFPersonNameParameter) -> Bool {
        return lhs.first == rhs.first &&
            lhs.last == rhs.last
    }
}

extension FFPersonParameter: Equatable {
    public static func ==(lhs: FFPersonParameter, rhs: FFPersonParameter) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name
    }
}

extension FFPersonPropertiesWithIsAdminParameter: Equatable {
    public static func ==(lhs: FFPersonPropertiesWithIsAdminParameter, rhs: FFPersonPropertiesWithIsAdminParameter) -> Bool {
        return lhs.id == rhs.id &&
            Calendar.current.isDate(lhs.signInDate, equalTo: rhs.signInDate, toGranularity: .nanosecond) &&
            lhs.name == rhs.name &&
            lhs.isAdmin == rhs.isAdmin
    }
}

extension FFPersonPropertiesWithUserIdParameter: Equatable {
    public static func ==(lhs: FFPersonPropertiesWithUserIdParameter, rhs: FFPersonPropertiesWithUserIdParameter) -> Bool {
        return lhs.id == rhs.id &&
            Calendar.current.isDate(lhs.signInDate, equalTo: rhs.signInDate, toGranularity: .nanosecond) &&
            lhs.name == rhs.name &&
            lhs.userId == rhs.userId
    }
}

extension FFReasonTemplateParameter: Equatable {
    public static func ==(lhs: FFReasonTemplateParameter, rhs: FFReasonTemplateParameter) -> Bool {
        return lhs.id == rhs.id &&
            lhs.reasonMessage == rhs.reasonMessage &&
            lhs.amount == rhs.amount &&
            lhs.importance == rhs.importance
    }
}

extension Bundle {
    enum SecretsPlistError: Error {
        case failedToGetPrivateKey
        case failedToGetTestUser
    }
    
    func plist(_ fileName: String) -> Dictionary<String, Any>? {
        guard let path = self.path(forResource: fileName, ofType: "plist") else {
            return nil
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        return try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? Dictionary<String, Any>
    }
    
    var plistSecretsPrivateKey: String? {
        let plist = self.plist("Secrets-Info")
        return plist?["FF_PRIVATE_KEY"] as? String
    }
    
    var plistSecretsTestUser: (email: String, password: String)? {
        let plist = self.plist("Secrets-Info")
        guard let testUser = plist?["FA_TEST_USER"] as? Dictionary<String, Any>,
              let email = testUser["EMAIL"] as? String,
              let password = testUser["PASSWORD"] as? String else {
                  return nil
              }
        return (email: email, password: password)
    }
}

extension FFCaller {
    func callTesting<FunctionCall>(_ functionCall: FunctionCall) async throws -> FunctionCall.ReturnType where FunctionCall : FFCallable {
        guard let privateKey = Bundle.main.plistSecretsPrivateKey else {
            throw Bundle.SecretsPlistError.failedToGetPrivateKey
        }
        return try await self.privateKey(privateKey).forTesting.call(functionCall)
    }
    
    func callTesting<FunctionCall>(_ functionCall: FunctionCall) async throws where FunctionCall: FFCallable, FunctionCall.ReturnType == FFVoidReturnType {
        guard let privateKey = Bundle.main.plistSecretsPrivateKey else {
            throw Bundle.SecretsPlistError.failedToGetPrivateKey
        }
        try await self.privateKey(privateKey).forTesting.call(functionCall)
    }
}
    
extension FRDFetcher {
    public func fetchTesting<Value>(_ type: Value.Type, from relativeUrl: URL) async throws -> Dictionary<String, Value>.Element where Value: Decodable {
        try await self.forTesting.fetch(Value.self, from: relativeUrl)
    }
    
    public func fetchChildrenTesting<Value>(_ type: Value.Type, from relativeUrl: URL) async throws -> Dictionary<String, Value> where Value: Decodable {
        try await self.forTesting.fetchChildren(Value.self, from: relativeUrl)
    }
    
    public func fetchPersonsTesting(of clubId: UUID) async throws -> Dictionary<String, FRDPerson> {
        return try await self.forTesting.fetchPersons(of: clubId)
    }
    
    public func fetchReasonTemplatessTesting(of clubId: UUID) async throws -> Dictionary<String, FRDReasonTemplate> {
        return try await self.forTesting.fetchReasonTemplates(of: clubId)
    }
    
    public func fetchFinesTesting(of clubId: UUID) async throws -> Dictionary<String, FRDFine> {
        return try await self.forTesting.fetchFines(of: clubId)
    }
}

extension FAuthenticator {
    @discardableResult
    public func signInTesting() async throws -> AuthDataResult {
        guard let testUser = Bundle.main.plistSecretsTestUser else {
            throw Bundle.SecretsPlistError.failedToGetTestUser
        }
        return try await self.signIn(email: testUser.email, password: testUser.password)
    }
}

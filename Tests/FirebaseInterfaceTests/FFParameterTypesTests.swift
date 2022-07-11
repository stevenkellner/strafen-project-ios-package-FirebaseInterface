//
//  FFParameterTypesTests.swift
//
//
//  Created by Steven on 15.06.22.
//

import XCTest
import Crypter
import StrafenProjectTypes
@testable import FirebaseInterface

fileprivate func parseType<T>(_ type: T.Type, from json: String) throws -> T where T: Decodable {
    let data = json.data(using: .utf8)
    XCTAssertNotNil(data)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601WithMilliseconds
    decoder.dataDecodingStrategy = .base64
    return try decoder.decode(T.self, from: data!)
}

final class FFParameterTypesTests: XCTestSuite {
    final class AmountTests: XCTestCase {
        func testValueNoNumber() {
            XCTAssertThrowsError(try parseType(FFAmountParameter.self, from: #""12.50""#))
        }
        
        func testValueNegativeNumber() {
            XCTAssertThrowsError(try parseType(FFAmountParameter.self, from: "-12.50"))
        }
        
        func testValueZeroNumber() throws {
            let amount = try parseType(FFAmountParameter.self, from: "0.0")
            XCTAssertEqual(amount, FFAmountParameter(value: 0, subUnitValue: 0))
            XCTAssertEqual(amount.internalParameter, 0.0)
        }
        
        func testValueLargeSubunitValue() throws {
            let amount = try parseType(FFAmountParameter.self, from: "1.298")
            XCTAssertEqual(amount, FFAmountParameter(value: 1, subUnitValue: 29))
            XCTAssertEqual(amount.internalParameter, 1.29)
        }
        
        func testValueNoSubunitValue() throws {
            let amount = try parseType(FFAmountParameter.self, from: "34")
            XCTAssertEqual(amount, FFAmountParameter(value: 34, subUnitValue: 0))
            XCTAssertEqual(amount.internalParameter, 34.0)
        }
    }
    
    final class ChangeTypeTests: XCTestCase {
        func testValueNoString() {
            XCTAssertThrowsError(try parseType(FFChangeTypeParameter.self, from: "12.5"))
        }
        
        func testInvalidValue() {
            XCTAssertThrowsError(try parseType(FFChangeTypeParameter.self, from: #""invalid""#))
        }
        
        func testValueUpdate() throws {
            let changeType = try parseType(FFChangeTypeParameter.self, from: #""update""#)
            XCTAssertEqual(changeType, .update)
            XCTAssertEqual(changeType.internalParameter, "update")
        }
        
        func testValueDelete() throws {
            let changeType = try parseType(FFChangeTypeParameter.self, from: #""delete""#)
            XCTAssertEqual(changeType, .delete)
            XCTAssertEqual(changeType.internalParameter, "delete")
        }
    }
    
    final class ClubPropertiesTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFClubPropertiesParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFClubPropertiesParameter.self, from: "{}"))
        }
        
        func testInvalidId() {
            XCTAssertThrowsError(try parseType(FFClubPropertiesParameter.self, from: """
                {
                    "id": "invalid",
                    "name": "test name",
                    "identifier": "test identifier",
                    "regionCode": "test region code",
                    "inAppPaymentActive": true
                }
            """))
        }
        
        func testValueValid() throws {
            let id = Club.ID(rawValue: UUID())
            let clubProperties = try parseType(FFClubPropertiesParameter.self, from: """
                {
                    "id": "\(id.uuidString)",
                    "name": "test name",
                    "identifier": "test identifier",
                    "regionCode": "test region code",
                    "inAppPaymentActive": true
                }
            """)
            XCTAssertEqual(clubProperties, FFClubPropertiesParameter(id: id, name: "test name", identifier: "test identifier", regionCode: "test region code", inAppPaymentActive: true))
            XCTAssertEqual(clubProperties.internalParameter, [
                "id": .string(id.uuidString),
                "name": "test name",
                "identifier": "test identifier",
                "regionCode": "test region code",
                "inAppPaymentActive": true
            ])
        }
    }
    
    final class DatabaseTypeTests: XCTestCase {
        func testValueNoString() {
            XCTAssertThrowsError(try parseType(DatabaseType.self, from: "12.5"))
        }
        
        func testInvalidValue() {
            XCTAssertThrowsError(try parseType(DatabaseType.self, from: #""invalid""#))
        }
        
        func testValueRelease() throws {
            let changeType = try parseType(DatabaseType.self, from: #""release""#)
            XCTAssertEqual(changeType, .release)
            XCTAssertEqual(changeType.internalParameter, "release")
        }
        
        func testValueDebug() throws {
            let changeType = try parseType(DatabaseType.self, from: #""debug""#)
            XCTAssertEqual(changeType, .debug)
            XCTAssertEqual(changeType.internalParameter, "debug")
        }
        
        func testValueTesting() throws {
            let changeType = try parseType(DatabaseType.self, from: #""testing""#)
            XCTAssertEqual(changeType, .testing)
            XCTAssertEqual(changeType.internalParameter, "testing")
        }
    }
    
    final class DeletableTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFDeletableParameter<FFAmountParameter, UUID>.self, from: #""asdf""#) as FFDeletableParameter<FFAmountParameter, UUID>)
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFDeletableParameter<FFAmountParameter, UUID>.self, from: "{}") as FFDeletableParameter<FFAmountParameter, UUID>)
        }
        
        func testDeletedFalseNoItem() {
            XCTAssertThrowsError(try parseType(FFDeletableParameter<FFAmountParameter, UUID>.self, from: """
                    {
                        "id": "\(UUID().uuidString)",
                        "deleted": false
                    }
            """) as FFDeletableParameter<FFAmountParameter, UUID>)
        }
        
        func testDeletedFalse() throws {
            let id = Club.ID(rawValue: UUID())
            let deletable: FFDeletableParameter<FFClubPropertiesParameter, UUID> = try parseType(FFDeletableParameter<FFClubPropertiesParameter, UUID>.self, from: """
                    {
                        "id": "\(id.uuidString)",
                        "deleted": false,
                        "name": "test name",
                        "identifier": "test identifier",
                        "regionCode": "test region code",
                        "inAppPaymentActive": true
                    }
            """)
            XCTAssertEqual(deletable, FFDeletableParameter<FFClubPropertiesParameter, UUID>.item(value: FFClubPropertiesParameter(id: id, name: "test name", identifier: "test identifier", regionCode: "test region code", inAppPaymentActive: true)))
            XCTAssertEqual(deletable.internalParameter, [
                "id": .string(id.uuidString),
                "name": "test name",
                "identifier": "test identifier",
                "regionCode": "test region code",
                "inAppPaymentActive": true
            ])
        }
        
        func testDeletedNoId() {
            XCTAssertThrowsError(try parseType(FFDeletableParameter<FFAmountParameter, UUID>.self, from: """
                    {
                        "deleted": true
                    }
            """) as FFDeletableParameter<FFAmountParameter, UUID>)
        }
        
        func testDeletedTrue1() throws {
            let id = UUID()
            let deletable: FFDeletableParameter<FFAmountParameter, UUID> = try parseType(FFDeletableParameter<FFAmountParameter, UUID>.self, from: """
                    {
                        "id": "\(id.uuidString)",
                        "deleted": true
                    }
            """)
            XCTAssertEqual(deletable, FFDeletableParameter<FFAmountParameter, UUID>.deleted(with: id))
        }
        
        func testDeletedTrue2() throws {
            let id = Club.ID(rawValue: UUID())
            let deletable: FFDeletableParameter<FFClubPropertiesParameter, Club.ID> = try parseType(FFDeletableParameter<FFClubPropertiesParameter, Club.ID>.self, from: """
                    {
                        "id": "\(id.uuidString)",
                        "deleted": true
                    }
            """)
            XCTAssertEqual(deletable, FFDeletableParameter<FFClubPropertiesParameter, Club.ID>.deleted(with: id))
            XCTAssertEqual(deletable.internalParameter, [
                "id": .string(id.uuidString),
                "deleted": true
            ])
        }
        
        func testItem() throws {
            let id = Club.ID(rawValue: UUID())
            let deletable: FFDeletableParameter<FFClubPropertiesParameter, Club.ID> = try parseType(FFDeletableParameter<FFClubPropertiesParameter, Club.ID>.self, from: """
                    {
                        "id": "\(id.uuidString)",
                        "name": "test name",
                        "identifier": "test identifier",
                        "regionCode": "test region code",
                        "inAppPaymentActive": true
                    }
            """)
            XCTAssertEqual(deletable, FFDeletableParameter<FFClubPropertiesParameter, Club.ID>.item(value: FFClubPropertiesParameter(id: id, name: "test name", identifier: "test identifier", regionCode: "test region code", inAppPaymentActive: true)))
            XCTAssertEqual(deletable.internalParameter, [
                "id": .string(id.uuidString),
                "name": "test name",
                "identifier": "test identifier",
                "regionCode": "test region code",
                "inAppPaymentActive": true
            ])
        }
    }
    
    final class FineTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFFineParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFFineParameter.self, from: "{}"))
        }
                
        func testValueValid() throws {
            let id = Fine.ID(rawValue: UUID())
            let personId = Person.ID(rawValue: UUID())
            let reasonTemplateId = ReasonTemplate.ID(rawValue: UUID())
            let date = Date()
            let fine = try parseType(FFFineParameter.self, from: """
                {
                    "id": "\(id.uuidString)",
                    "personId": "\(personId.uuidString)",
                    "payedState": {
                        "state": "settled",
                    },
                    "number": 1,
                    "date": "\(date.ISO8601Format(.iso8601))",
                    "fineReason": {
                        "reasonTemplateId": "\(reasonTemplateId.uuidString)"
                    }
                }
            """)
            XCTAssertEqual(fine, FFFineParameter(id: id, personId: personId, payedState: .settled, number: 1, date: date, fineReason: .template(reasonTemplateId: reasonTemplateId)))
            XCTAssertEqual(fine.internalParameter, [
                "id": .string(id.uuidString),
                "personId": .string(personId.uuidString),
                "payedState": [
                    "state": "settled"
                ],
                "number": .uint(1),
                "date": .string(date.ISO8601Format(.iso8601)),
                "fineReason": [
                    "reasonTemplateId": .string(reasonTemplateId.uuidString)
                ]
            ])
        }
    }
        
    final class FineReasonTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFFineReasonParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFFineReasonParameter.self, from: "{}"))
        }
        
        func testValueCustomAndTemplate() throws {
            let reasonTemplateId = ReasonTemplate.ID(rawValue: UUID())
            let fineReason = try parseType(FFFineReasonParameter.self, from: """
                {
                    "reasonTemplateId": "\(reasonTemplateId.uuidString)",
                    "reasonMessage": "asdf",
                    "amount": 12.50,
                    "importance": "high"
                }
            """)
            XCTAssertEqual(fineReason, FFFineReasonParameter.template(reasonTemplateId: reasonTemplateId))
            XCTAssertEqual(fineReason.internalParameter, [
                "reasonTemplateId": .string(reasonTemplateId.uuidString)
            ])
        }
        
        func testValueTemplate() throws {
            let reasonTemplateId = ReasonTemplate.ID(rawValue: UUID())
            let fineReason = try parseType(FFFineReasonParameter.self, from: """
                {
                    "reasonTemplateId": "\(reasonTemplateId.uuidString)"
                }
            """)
            XCTAssertEqual(fineReason, FFFineReasonParameter.template(reasonTemplateId: reasonTemplateId))
            XCTAssertEqual(fineReason.internalParameter, [
                "reasonTemplateId": .string(reasonTemplateId.uuidString)
            ])
        }
        
        func testValueCustom() throws {
            let fineReason = try parseType(FFFineReasonParameter.self, from: """
                {
                    "reasonMessage": "asdf",
                    "amount": 12.50,
                    "importance": "high"
                }
            """)
            XCTAssertEqual(fineReason, FFFineReasonParameter.custom(reasonMessage: "asdf", amount: FFAmountParameter(value: 12, subUnitValue: 50), importance: .high))
            XCTAssertEqual(fineReason.internalParameter, [
                "reasonMessage": "asdf",
                "amount": 12.50,
                "importance": "high"
            ])
        }
    }
    
    final class ImportanceTests: XCTestCase {
        func testNoString() {
            XCTAssertThrowsError(try parseType(FFImportanceParameter.self, from: "12.50"))
        }
        
        func testInvalidString() {
            XCTAssertThrowsError(try parseType(FFImportanceParameter.self, from: #""asdf""#))
        }
        
        func testValueHigh() throws {
            let importance = try parseType(FFImportanceParameter.self, from: #""high""#)
            XCTAssertEqual(importance, FFImportanceParameter.high)
            XCTAssertEqual(importance.internalParameter, "high")
        }
        
        func testValueMedium() throws {
            let importance = try parseType(FFImportanceParameter.self, from: #""medium""#)
            XCTAssertEqual(importance, FFImportanceParameter.medium)
            XCTAssertEqual(importance.internalParameter, "medium")
        }
        
        func testValueLow() throws {
            let importance = try parseType(FFImportanceParameter.self, from: #""low""#)
            XCTAssertEqual(importance, FFImportanceParameter.low)
            XCTAssertEqual(importance.internalParameter, "low")
        }
    }
    
    final class LatePaymentInterestTests: XCTestCase {
        func testTimePeriodNoObject() {
            XCTAssertThrowsError(try parseType(FFLatePaymentInterestParameter.TimePeriod.self, from: "12.50"))
        }
        
        func testTimePeriodInvalidObject() {
            XCTAssertThrowsError(try parseType(FFLatePaymentInterestParameter.TimePeriod.self, from: "{}"))
        }
        
        func testTimePeriodInvalidUnit() {
            XCTAssertThrowsError(try parseType(FFLatePaymentInterestParameter.TimePeriod.self, from: """
                {
                    "value": 12,
                    "unit": "asdf"
                }
            """))
        }
        
        func testTimePeriodUnitDay() throws {
            let timePeriod = try parseType(FFLatePaymentInterestParameter.TimePeriod.self, from: """
                {
                    "value": 12,
                    "unit": "day"
                }
            """)
            XCTAssertEqual(timePeriod, FFLatePaymentInterestParameter.TimePeriod(value: 12, unit: .day))
            XCTAssertEqual(timePeriod.internalParameter, [
                "value": 12,
                "unit": "day"
            ])
        }
        
        func testTimePeriodUnitMonth() throws {
            let timePeriod = try parseType(FFLatePaymentInterestParameter.TimePeriod.self, from: """
                {
                    "value": 12,
                    "unit": "month"
                }
            """)
            XCTAssertEqual(timePeriod, FFLatePaymentInterestParameter.TimePeriod(value: 12, unit: .month))
            XCTAssertEqual(timePeriod.internalParameter, [
                "value": 12,
                "unit": "month"
            ])
        }
        
        func testTimePeriodUnitYear() throws {
            let timePeriod = try parseType(FFLatePaymentInterestParameter.TimePeriod.self, from: """
                {
                    "value": 12,
                    "unit": "year"
                }
            """)
            XCTAssertEqual(timePeriod, FFLatePaymentInterestParameter.TimePeriod(value: 12, unit: .year))
            XCTAssertEqual(timePeriod.internalParameter, [
                "value": 12,
                "unit": "year"
            ])
        }
        
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFLatePaymentInterestParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFLatePaymentInterestParameter.self, from: "{}"))
        }
        
        func testValueValid() throws {
            let latePaymentInterest = try parseType(FFLatePaymentInterestParameter.self, from: """
                {
                    "interestFreePeriod": {
                        "value": 10,
                        "unit": "day"
                    },
                    "interestPeriod": {
                        "value": 2,
                        "unit": "year"
                    },
                    "interestRate": 1.2,
                    "compoundInterest": true
                }
            """)
            XCTAssertEqual(latePaymentInterest, FFLatePaymentInterestParameter(interestFreePeriod: FFLatePaymentInterestParameter.TimePeriod(value: 10, unit: .day), interestPeriod: FFLatePaymentInterestParameter.TimePeriod(value: 2, unit: .year), interestRate: 1.2, compoundInterest: true))
            XCTAssertEqual(latePaymentInterest.internalParameter, [
                "interestFreePeriod": [
                    "value": 10,
                    "unit": "day"
                ],
                "interestPeriod": [
                    "value": 2,
                    "unit": "year"
                ],
                "interestRate": 1.2,
                "compoundInterest": true
            ])
        }
    }
    
    final class PayedStateTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFPayedStateParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFPayedStateParameter.self, from: "{}"))
        }
        
        func testValueUnpayed() throws {
            let payedState = try parseType(FFPayedStateParameter.self, from: """
                {
                    "state": "unpayed"
                }
            """)
            XCTAssertEqual(payedState, FFPayedStateParameter.unpayed)
            XCTAssertEqual(payedState.internalParameter, [
                "state": "unpayed"
            ])
        }
        
        func testValueSettled() throws {
            let payedState = try parseType(FFPayedStateParameter.self, from: """
                {
                    "state": "settled"
                }
            """)
            XCTAssertEqual(payedState, FFPayedStateParameter.settled)
            XCTAssertEqual(payedState.internalParameter, [
                "state": "settled"
            ])
        }
        
        func testValuePayed() throws {
            let payDate = Date()
            let payedState = try parseType(FFPayedStateParameter.self, from: """
                {
                    "state": "payed",
                    "inApp": true,
                    "payDate": "\(payDate.ISO8601Format(.iso8601))"
                }
            """)
            XCTAssertEqual(payedState, FFPayedStateParameter.payed(inApp: true, payDate: payDate))
            XCTAssertEqual(payedState.internalParameter, [
                "state": "payed",
                "inApp": true,
                "payDate": .string(payDate.ISO8601Format(.iso8601))
            ])
        }
    }
    
    final class PersonTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFPersonParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFPersonParameter.self, from: "{}"))
        }
        
        func testValueValid() throws {
            let id = Person.ID(rawValue: UUID())
            let person = try parseType(FFPersonParameter.self, from: """
                {
                    "id": "\(id.uuidString)",
                    "name": {
                        "first": "asdf",
                        "last": "ölkj"
                    }
                }
            """)
            XCTAssertEqual(person, FFPersonParameter(id: id, name: FFPersonNameParameter(first: "asdf", last: "ölkj")))
            XCTAssertEqual(person.internalParameter, [
                "id": .string(id.uuidString),
                "name": [
                    "first": "asdf",
                    "last": .optional("ölkj")
                ]
            ])
        }
    }
    
    final class PersonNameTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFPersonNameParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFPersonNameParameter.self, from: "{}"))
        }
        
        func testValueValid() throws {
            let personName = try parseType(FFPersonNameParameter.self, from: """
                {
                    "first": "g",
                    "last": "f"
                }
            """)
            XCTAssertEqual(personName, FFPersonNameParameter(first: "g", last: "f"))
            XCTAssertEqual(personName.internalParameter, [
                "first": "g",
                "last": .optional("f")
            ])
        }
        
        func testValueValidNoLast() throws {
            let personName = try parseType(FFPersonNameParameter.self, from: """
                {
                    "first": "h"
                }
            """)
            XCTAssertEqual(personName, FFPersonNameParameter(first: "h"))
            XCTAssertEqual(personName.internalParameter, [
                "first": "h",
                "last": nil
            ])
        }
    }
    
    final class PersonPropertiesWithIsAdminTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFPersonPropertiesWithIsAdminParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFPersonPropertiesWithIsAdminParameter.self, from: "{}"))
        }
        
        func testValueValid() throws {
            let id = Person.ID(rawValue: UUID())
            let signInDate = Date()
            let personProperties = try parseType(FFPersonPropertiesWithIsAdminParameter.self, from: """
                {
                    "id": "\(id.uuidString)",
                    "signInDate": "\(signInDate.ISO8601Format(.iso8601))",
                    "isAdmin": true,
                    "name": {
                        "first": "asdf"
                    }
                }
            """)
            XCTAssertEqual(personProperties, FFPersonPropertiesWithIsAdminParameter(id: id, signInDate: signInDate, isAdmin: true, name: FFPersonNameParameter(first: "asdf")))
            XCTAssertEqual(personProperties.internalParameter, [
                "id": .string(id.uuidString),
                "signInDate": .string(signInDate.ISO8601Format(.iso8601)),
                "isAdmin": true,
                "name": [
                    "first": "asdf",
                    "last": nil
                ]
            ])
        }
    }
    
    final class PersonPropertiesWithUserIdTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFPersonPropertiesWithUserIdParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFPersonPropertiesWithUserIdParameter.self, from: "{}"))
        }
        
        func testValueValid() throws {
            let id = Person.ID(rawValue: UUID())
            let signInDate = Date()
            let personProperties = try parseType(FFPersonPropertiesWithUserIdParameter.self, from: """
                {
                    "id": "\(id.uuidString)",
                    "signInDate": "\(signInDate.ISO8601Format(.iso8601))",
                    "userId": "ölkj",
                    "name": {
                        "first": "asdf"
                    }
                }
            """)
            XCTAssertEqual(personProperties, FFPersonPropertiesWithUserIdParameter(id: id, signInDate: signInDate, userId: "ölkj", name: FFPersonNameParameter(first: "asdf")))
            XCTAssertEqual(personProperties.internalParameter, [
                "id": .string(id.uuidString),
                "signInDate": .string(signInDate.ISO8601Format(.iso8601)),
                "userId": "ölkj",
                "name": [
                    "first": "asdf",
                    "last": nil
                ]
            ])
        }
    }
    
    final class ReasonTemplateTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFReasonTemplateParameter.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFReasonTemplateParameter.self, from: "{}"))
        }
        
        func testValueValid() throws {
            let id = ReasonTemplate.ID(rawValue: UUID())
            let reasonTemplate = try parseType(FFReasonTemplateParameter.self, from: """
                {
                    "id": "\(id.uuidString)",
                    "reasonMessage": "message",
                    "amount": 23.45,
                    "importance": "high"
                }
            """)
            XCTAssertEqual(reasonTemplate, FFReasonTemplateParameter(id: id, reasonMessage: "message", amount: FFAmountParameter(value: 23, subUnitValue: 45), importance: .high))
            XCTAssertEqual(reasonTemplate.internalParameter, [
                "id": .string(id.uuidString),
                "reasonMessage": "message",
                "amount": 23.45,
                "importance": "high"
            ])
        }
    }
    
    final class UpdatableTests: XCTestCase {
        func testNoObject() {
            XCTAssertThrowsError(try parseType(FFUpdatableParameter<FFPersonParameter>.self, from: "12.50"))
        }
        
        func testInvalidObject() {
            XCTAssertThrowsError(try parseType(FFUpdatableParameter<FFPersonParameter>.self, from: "{}"))
        }
        
        func testValueValid() throws {
            let id = Person.ID(rawValue: UUID())
            let personId = Person.ID(rawValue: UUID())
            let timestamp = Date()
            let updatable = try parseType(FFUpdatableParameter<FFPersonParameter>.self, from: """
                {
                    "id": "\(id.uuidString)",
                    "name": {
                        "first": "fn",
                        "last": "ln"
                    },
                    "updateProperties": {
                        "personId": "\(personId.uuidString)",
                        "timestamp": "\(timestamp.ISO8601Format(.iso8601))"
                    }
                }
            """)
            XCTAssertEqual(updatable, FFUpdatableParameter(property: FFPersonParameter(id: id, name: FFPersonNameParameter(first: "fn", last: "ln")), updateProperties: FFUpdatableParameter.UpdateProperties(timestamp: timestamp, personId: personId)))
            XCTAssertEqual(updatable.internalParameter, [
                "id": .string(id.uuidString),
                "name": [
                    "first": "fn",
                    "last": .optional("ln")
                ],
                "updateProperties": [
                    "personId": .string(personId.uuidString),
                    "timestamp": .string(timestamp.ISO8601Format(.iso8601))
                ]
            ])
        }
    }
}

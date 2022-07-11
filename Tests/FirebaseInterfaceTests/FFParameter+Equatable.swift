//
//  FFParameter+Equatable.swift
//  
//
//  Created by Steven on 02.07.22.
//

import Foundation
@testable import FirebaseInterface

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
        case (.deleted(with: let lhsId), .deleted(with: let rhsId)):
            return lhsId == rhsId
        case (.item(value: let lhsItem), .item(value: let rhsItem)):
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

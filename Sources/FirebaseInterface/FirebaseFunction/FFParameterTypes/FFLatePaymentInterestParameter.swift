//
//  FFLatePaymentInterestParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Late payement interest
public struct FFLatePaymentInterestParameter {
    
    /// Interestfree period of the late payment interest.
    public private(set) var interestFreePeriod: TimePeriod
    
    /// Interest period of the late payment interest.
    public private(set) var interestPeriod: TimePeriod
    
    /// Interest rate of the late payment interest.
    public private(set) var interestRate: Double
    
    /// Compound interest of the late payment interest.
    public private(set) var compoundInterest: Bool
}

extension FFLatePaymentInterestParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        return [
            "interestFreePeriod": self.interestFreePeriod,
            "interestPeriod": self.interestPeriod,
            "interestRate": self.interestRate,
            "compoundInterest": self.compoundInterest
        ]
    }
}

extension FFLatePaymentInterestParameter: Decodable {}

extension FFLatePaymentInterestParameter: ILatePaymentInterest {

    /// Initializes late payment interest with a `ILatePaymentInterest` protocol.
    /// - Parameter latePaymentInterest: `ILatePaymentInterest` protocol to initialize the late payment interest.
    public init(_ latePaymentInterest: some ILatePaymentInterest) {
        self.interestFreePeriod = TimePeriod(latePaymentInterest.interestFreePeriod)
        self.interestPeriod = TimePeriod(latePaymentInterest.interestPeriod)
        self.interestRate = latePaymentInterest.interestRate
        self.compoundInterest = latePaymentInterest.compoundInterest
    }
}

extension FFLatePaymentInterestParameter {

    /// Contains a value and an unit of `day`, `month`, `year`.
    public struct TimePeriod {

        /// Value of the time period.
        public private(set) var value: UInt

        /// Unit of the time period.
        public private(set) var unit: Unit
    }
}

extension FFLatePaymentInterestParameter.TimePeriod: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        return [
            "value": self.value,
            "unit": self.unit
        ]
    }
}

extension FFLatePaymentInterestParameter.TimePeriod: Decodable {}

extension FFLatePaymentInterestParameter.TimePeriod: ITimePeriod {

    /// Initializes time period with a `ITimePeriod` protocol.
    /// - Parameter timePeriod: `ITimePeriod` protocol to initialize the time period.
    public init(_ timePeriod: some ITimePeriod) {
        self.value = timePeriod.value
        self.unit = Unit(timePeriod.unit)
    }
}

extension FFLatePaymentInterestParameter.TimePeriod {

    /// Unit of a time period.
    public enum Unit: String {

        /// Day unit of a time period.
        case day

        /// Month unit of a time period.
        case month

        /// Year unit of a time period.
        case year
    }
}

extension FFLatePaymentInterestParameter.TimePeriod.Unit: FFParameterType {
    public var parameter: String {
        return self.rawValue
    }
}

extension FFLatePaymentInterestParameter.TimePeriod.Unit: Decodable {}

extension FFLatePaymentInterestParameter.TimePeriod.Unit: ITimePeriodUnit {

    /// Initializes time period unit with a `ITimePeriodUnit` protocol.
    /// - Parameter timePeriodUnit: `ITimePeriodUnit` protocol to initialize the time period unit.
    public init(_ timePeriodUnit: some ITimePeriodUnit) {
        switch timePeriodUnit.concreteTimePeriodUnit {
        case .day: self = .day
        case .month: self = .month
        case .year: self = .year
        }
    }

    public var concreteTimePeriodUnit: TimePeriodUnit {
        switch self {
        case .day: return .day
        case .month: return .month
        case .year: return .year
        }
    }
}

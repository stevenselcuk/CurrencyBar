//
//  Money.swift
//  YouBar
//
//  Created by Steven J. Selcuk on 16.08.2022.
//

import Foundation

public protocol ComparableToZero {
    /// - returns: True if the amount is exactly zero.
    var isZero: Bool { get }

    /// - returns: True if the rounded amount is positive, i.e. zero or more.
    var isPositive: Bool { get }

    /// - returns: True if the rounded amount is less than zero, or false if the amount is zero or more.
    var isNegative: Bool { get }

    /// - returns: True if the rounded amount is greater than zero, or false if the amount is zero or less.
    var isGreaterThanZero: Bool { get }
}

extension Decimal {
    public var asDecimalNumber: NSDecimalNumber {
        self as NSDecimalNumber
    }

    /// The double value of the decimal number.
    public var doubleValue: Double {
        asDecimalNumber.doubleValue
    }

    private static let decimalHandler = NSDecimalNumberHandler(
        roundingMode: .bankers,
        scale: 2,
        raiseOnExactness: true,
        raiseOnOverflow: true,
        raiseOnUnderflow: true,
        raiseOnDivideByZero: true
    )

    /// Returns the number rounded to two decimals.
    /// Using this help prevent incorrect values especially during serialization.
    public var rounded: Self {
        NSDecimalNumber(decimal: self) // swiftlint:disable:this legacy_objc_type
            .rounding(accordingToBehavior: Self.decimalHandler)
            .decimalValue
    }
}

public struct CurrencyFormatter {
    /// The users locale.
    public let locale: Locale

    /// The currency to use when formatting.
    public let currency: Currency

    private let formatter = NumberFormatter.currency

    /// Initialize a new formatter with a specified currency and locale.
    /// Locale is an optional parameter and defaults to `.autoupdatingCurrent`.
    public init(currency: Currency, locale: Locale = .autoupdatingCurrent) {
        self.currency = currency
        self.locale = locale

        formatter.locale = locale
        formatter.currencyCode = currency.code

        if currency.code == .none {
            formatter.numberStyle = .decimal
        }
    }

    /// Returns the decimal value from a formatted string, or nil if parsing fails.
    public func decimal(from string: String) -> Decimal? {
        guard let number = formatter.number(from: string) else {
            return nil
        }
        return number.decimalValue
    }

    /// Returns the `Money` value from a formatted string, or nil if parsing fails.
    public func money(from string: String) -> Money? {
        guard let number = formatter.number(from: string) else {
            return nil
        }
        return Money(number.decimalValue, in: currency)
    }

    /// Returns a formatted string from a number, or nil if formatting fails.
    public func string(from number: Decimal) -> String? {
        formatter.string(from: number.rounded.asDecimalNumber)
    }

    /// Returns a formatted string from a `Money`-value, or nil if formatting fails.
    public func string(from money: Money) -> String? {
        formatter.string(from: money.amount.asDecimalNumber)
    }
}

extension NumberFormatter {
    public static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    public static var monetary: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = true
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }
}

extension NumberFormatter {
    public func money(from string: String, in currency: Currency) -> Money? {
        guard let number = number(from: string) else {
            return nil
        }
        return Money(number.decimalValue, in: currency)
    }

    public func string(fromMoney money: Money) -> String? {
        string(fromDecimal: money.amount)
    }

    public func string(fromDecimal number: Decimal) -> String? {
        string(from: number.rounded.asDecimalNumber)
    }
}

/// An amount of money in a given currency.
public struct Money: Hashable {
    private static let decimalHandler = NSDecimalNumberHandler(
        roundingMode: .bankers,
        scale: 2,
        raiseOnExactness: true,
        raiseOnOverflow: true,
        raiseOnUnderflow: true,
        raiseOnDivideByZero: true
    )

    /// - returns: Rounded amount of money in decimal using NSDecimalNumberHandler
    public var amount: Decimal {
        rawValue.rounded
    }

    /// - returns: Formatted rounded amount with currency symbol.
    /// If `currency` is not set, returns the formatted amount without currency.
    public var formattedString: String? {
        if let currency = currency {
            let formatter = CurrencyFormatter(currency: currency, locale: .current)
            return formatter.string(from: self)
        } else {
            return NumberFormatter.monetary.string(from: amount.asDecimalNumber)
        }
    }

    public let currency: Currency?

    /// The raw decimal value. Do not use this directly as it can cause rounding issues.
    /// Instead get the amount-value using the `rounded` property.
    private let rawValue: Decimal

    /// Creates an amount of money with a given decimal number, and optional currency.
    /// - Parameters:
    ///   - amount: An amount of money.
    ///   - currency: A currency the money is in, or nil if no particular currency is needed.
    public init(_ amount: Decimal, in currency: Currency? = nil) {
        rawValue = amount
        self.currency = currency
    }

    /// Creates an amount of money with a given double number, and optional currency.
    /// - Parameters:
    ///   - amount: An amount of money.
    ///   - currency: A currency the money is in, or nil if no particular currency is needed.
    public init(amount: Double, in currency: Currency? = nil) {
        rawValue = Decimal(amount)
        self.currency = currency
    }

    // MARK: - Arithmetic

    /// Creates an amount of money with a given string number, and optional currency, or returns nil if the string is not a valid number.
    /// - Parameters:
    ///   - string: An amount of money from string.
    ///   - currency: A currency the money is in, or nil if no particular currency is needed.
    public init?(string: String, in currency: Currency? = nil) {
        guard let doubleValue = Double(string) else {
            return nil
        }

        rawValue = Decimal(doubleValue)
        self.currency = currency
    }

    /// Add two money amounts. This function does not take different currencies into account.
    public static func + (lhs: Money, rhs: Money) -> Money {
        Money(lhs.rawValue + rhs.rawValue)
    }

    /// Subtract two money amounts. This function does not take different currencies into account.
    public static func - (lhs: Money, rhs: Money) -> Money {
        Money(lhs.rawValue - rhs.rawValue)
    }

    /// Multiply two money amounts. This function does not take different currencies into account.
    public static func * (lhs: Money, rhs: Money) -> Money {
        Money(lhs.rawValue * rhs.rawValue)
    }

    /// Divide two money amounts. This function does not take different currencies into account.
    public static func / (lhs: Money, rhs: Money) -> Money? {
        guard !rhs.isZero else {
            return nil
        }
        return Money(lhs.rawValue / rhs.rawValue)
    }
}

// MARK: - ComparableToZero

extension Money: ComparableToZero {
    /// - returns: True if the amount is exactly zero.
    public var isZero: Bool {
        amount.isZero
    }

    /// - returns: True if the rounded amount is positive, i.e. zero or more.
    public var isPositive: Bool {
        isZero || isGreaterThanZero
    }

    /// - returns: True if the rounded amount is less than zero, or false if the amount is zero or more.
    public var isNegative: Bool {
        amount < 0.0
    }

    /// - returns: True if the rounded amount is greater than zero, or false if the amount is zero or less.
    public var isGreaterThanZero: Bool {
        amount > 0.0
    }
}

// MARK: - CustomStringConvertible

extension Money: CustomStringConvertible {
    public var description: String {
        "\(amount)"
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Money: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = Money(Decimal(value))
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Money: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double

    public init(floatLiteral value: Self.FloatLiteralType) {
        self = Self(Decimal(value))
    }
}

// MARK: - Equatable

extension Money: Equatable {
    public static func == (lhs: Money, rhs: Money) -> Bool {
        lhs.amount == rhs.amount
    }
}

// MARK: - Comparable

extension Money: Comparable {
    public static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.amount < rhs.amount
    }
}

// MARK: - Codable

extension Money: Codable {
    public init(from decoder: Decoder) throws {
        if let singleValueContainer = try? decoder.singleValueContainer() {
            var amount: Double?
            if let double = try? singleValueContainer.decode(Double.self) {
                amount = double
            }

            if let amount = amount {
                rawValue = Decimal(amount)
                currency = .none
            } else {
                throw DecodingError.dataCorruptedError(in: singleValueContainer, debugDescription: "Could not decode value for amount")
            }
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode Money value")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(amount)
    }
}

// MARK: - Convert to Money

extension Decimal {
    /// Convert a decimal number to `Money` in a given currency.
    /// - Parameter currency: A currency the money is in.
    /// - Returns: A new `Money` with the current amount in the given currency.
    public func `in`(_ currency: Currency) -> Money {
        Money(self, in: currency)
    }
}

// MARK: - Sum and Average

extension Collection where Element == Money {
    /// Returns the sum of the money in the collection.
    /// All elements must have the same currency (or none), otherwise this returns nil.
    public var sum: Money? {
        let uniqueElements = Set(map(\.currency))
        guard uniqueElements.count == 1 else {
            return nil
        }
        return reduce(0, +)
    }

    /// Returns the average of the money in the collection, or zero if the collection is empty
    /// All elements must have the same currency (or none), otherwise this returns nil.
    public var average: Money? {
        guard !isEmpty else {
            return Money(0)
        }

        let uniqueElements = Set(map(\.currency))
        guard uniqueElements.count == 1,
              let sum = sum else {
            return nil
        }

        return sum / Money(Decimal(count))
    }
}

//
//  Currency.swift
//  YouBar
//
//  Created by Steven J. Selcuk on 16.08.2022.
//

import Foundation

/// Currency represents the basic attributes of a currency like its currency code.
/// You would normally not need to construct your own currency, but can instead access one using `Currency(code:)`.
public struct Currency: Codable, Hashable {

    public var localizedName: String? {
        locale.localizedString(forCurrencyCode: code)
    }

    /// The ISO 4217 currency code identifying the currency, e.g. GBP.
    public let code: String

    public let locale: Locale

    public var symbol: String {
        let code = code
        let locale = NSLocale(localeIdentifier: code) // swiftlint:disable:this legacy_objc_type
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newLocale = NSLocale(localeIdentifier: code.dropLast() + "_en") // swiftlint:disable:this legacy_objc_type
            return newLocale.displayName(forKey: .currencySymbol, value: code) ?? code
        }
        return locale.displayName(forKey: .currencySymbol, value: code) ?? code
    }

    public init(code: String, locale: Locale = .autoupdatingCurrent) {
        self.code = code
        self.locale = Locale.autoupdatingCurrent
    }

    public init?(codeString: String, locale: Locale = .autoupdatingCurrent) {
        self.code = codeString
        self.locale = locale
    }
}

extension Currency: Equatable {

    public static func == (lhs: Currency, rhs: Currency) -> Bool {
        lhs.code == rhs.code
    }
}

/// This extension provides a bridge to system APIs inside a convenient namespace.
extension Currency {

    /// The currency code of the users current locale.
    public static var currencyCode: String? {
        Locale.current.currencyCode
    }

    /// The currency symbol of the users current locale.
    public static var currencySymbol: String? {
        Locale.current.currencySymbol
    }

    /// A list of available currency codes.
    public static var isoCurrencyCodes: [String] {
        Locale.isoCurrencyCodes
    }

    /// A list of common currency codes.
    public static var commonIsoCurrencyCodes: [String] {
        Locale.commonISOCurrencyCodes
    }

    /// Returns a localized string for a specified ISO 4217 currency code.
    public static func localizedString(forCurrencyCode: String) -> String? {
        NSLocale.system.localizedString(forCurrencyCode: forCurrencyCode) // swiftlint:disable:this legacy_objc_type
    }
}

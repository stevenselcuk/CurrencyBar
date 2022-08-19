//
//  CurrencyHelpers.swift
//  Ticker
//
//  Created by Steven J. Selcuk on 18.08.2022.
//

import Foundation
import SwiftUI

class CurrencyManager: ObservableObject {
    
    @Published var string: String = ""
    @Published var amount: Decimal = 0.0
    @Published var formatter = NumberFormatter(numberStyle: .currency)
    @Published  var updateID: UUID = UUID()
    private var maximum: Decimal = 999_999_999.99
    private var lastValue: String = ""
    
    init(amount: Decimal, maximum: Decimal = 999_999_999.99, locale: Locale = .current) {
        formatter.locale = locale
        self.string = formatter.string(for: amount) ?? "$0.00"
        self.lastValue = string
        self.amount = amount
        self.maximum = maximum
    }
    
    func valueChanged(_ value: String) {
        let newValue = (value.decimal ?? .zero) / pow(10, formatter.maximumFractionDigits)
        if newValue > maximum {
            string = lastValue
            amount = string.decimal! / 100
            print(string.decimal!)
            print()
        } else {
            string = formatter.string(for: newValue) ?? "$0.00"
            lastValue = string
            amount = lastValue.decimal! / 100
        }
    }
}


extension NumberFormatter {
    
    convenience init(numberStyle: Style, locale: Locale = .current) {
        self.init()
        self.locale = locale
        self.numberStyle = numberStyle
        self.hasThousandSeparators = true
    }
}

extension Character {
    
    var isDigit: Bool { "0"..."9" ~= self }
}


extension LosslessStringConvertible {
    
    var string: String { .init(self) }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    
    var digits: Self { filter (\.isDigit) }
    
    var decimal: Decimal? { Decimal(string: digits.string) }
    
    var double: Double? { Double(digits.string) }
}


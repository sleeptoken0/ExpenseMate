//
//  MoneyFormatter.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation

enum MoneyFormatter {
    static func format(_ amount: Double, currency: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currency
        return f.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

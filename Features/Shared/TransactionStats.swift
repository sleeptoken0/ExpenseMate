//
//  TransactionStats.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation

struct TransactionStats: Equatable {
    var incomeTotal: Double
    var expenseTotal: Double

    var balance: Double { incomeTotal - expenseTotal }

    static let zero = TransactionStats(incomeTotal: 0, expenseTotal: 0)

    static func compute(
        transactions: [Transaction],
        in range: DateRange
    ) -> TransactionStats {
        var income: Double = 0
        var expense: Double = 0

        for tx in transactions where range.contains(tx.date) {
            switch tx.type {
            case .income:
                income += tx.amount
            case .expense:
                expense += tx.amount
            }
        }

        return TransactionStats(incomeTotal: income, expenseTotal: expense)
    }
}

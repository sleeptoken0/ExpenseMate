//
//  MiniChartsViewModel.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI
import SwiftData
import Combine

struct CategoryTotal: Identifiable {
    let id: UUID
    let name: String
    let iconName: String
    let colorKey: String
    let total: Double
}

@MainActor
final class MiniChartsViewModel: ObservableObject {
    @Published private(set) var incomeByCategory: [CategoryTotal] = []
    @Published private(set) var expenseByCategory: [CategoryTotal] = []
    @Published private(set) var incomeSum: Double = 0
    @Published private(set) var expenseSum: Double = 0

    func recompute(transactions: [Transaction], tab: HomeView.HomeTab) {
        // δουλεύουμε πάνω σε “month-filtered” transactions που θα του δίνεις από το view
        let income = transactions.filter { $0.type == .income }
        let expense = transactions.filter { $0.type == .expense }

        incomeSum = income.reduce(0) { $0 + $1.amount }
        expenseSum = expense.reduce(0) { $0 + $1.amount }

        incomeByCategory = Self.groupByCategory(income)
        expenseByCategory = Self.groupByCategory(expense)
    }

    private static func groupByCategory(_ txs: [Transaction]) -> [CategoryTotal] {
        let grouped = Dictionary(grouping: txs, by: { $0.category })
        return grouped.map { (cat, items) in
            CategoryTotal(
                id: cat.id,
                name: cat.name,
                iconName: cat.iconName,
                colorKey: cat.colorKey,
                total: items.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.total > $1.total }
    }
}

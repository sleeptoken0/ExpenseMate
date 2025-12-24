//
//  ChartsViewModel.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation
import Combine

@MainActor
final class ChartsViewModel: ObservableObject {

    @Published private(set) var output: ChartsOutput = .init(rows: [], transactionCount: 0, totalAmount: 0)

    func build(for tab: HomeView.HomeTab, transactions: [Transaction], monthAnchor: Date) {
        // 1) Φιλτράρουμε τύπο (Income/Expense/Balance)
        let typeFilter: TransactionType? = tab.typeFilter // income/expense ή nil για balance
        let filteredByType: [Transaction]
        if let typeFilter {
            filteredByType = transactions.filter { $0.type == typeFilter }
        } else {
            // balance = όλα (income + expense)
            filteredByType = transactions
        }

        // 2) Φιλτράρουμε μήνα (με βάση monthAnchor)
        let cal = Calendar.current
        guard let monthInterval = cal.dateInterval(of: .month, for: monthAnchor) else {
            output = .init(rows: [], transactionCount: 0, totalAmount: 0)
            return
        }

        let inMonth = filteredByType.filter { monthInterval.contains($0.date) }

        // 3) Υπολογισμοί ανά category
        // NOTE: Για balance λογική: income (+), expense (-)
        struct Agg {
            var amount: Double = 0
            var name: String = ""
            var icon: String = "questionmark.circle"
            var colorKey: String = "blue"
        }

        var map: [UUID: Agg] = [:]

        for t in inMonth {
            let cat = t.category
            var agg = map[cat.id] ?? Agg(amount: 0, name: cat.name, icon: cat.iconName, colorKey: cat.colorKey)

            switch tab {
            case .income:
                agg.amount += t.amount
            case .expense:
                agg.amount += t.amount
            case .balance:
                agg.amount += (t.type == .income ? t.amount : -t.amount)
            }

            map[cat.id] = agg
        }

        // 4) Total + percent
        let items = map.map { (key, value) in (id: key, agg: value) }

        // Για balance, τα percents τα θέλουμε σε σχέση με |sum| (για να βγει ωραίο bar)
        let totalForPercent: Double
        if tab == .balance {
            totalForPercent = items.reduce(0) { $0 + abs($1.agg.amount) }
        } else {
            totalForPercent = items.reduce(0) { $0 + $1.agg.amount }
        }

        let rows: [ChartRow] = items
            .map { item in
                let pct: Double
                if totalForPercent == 0 {
                    pct = 0
                } else {
                    pct = (tab == .balance)
                    ? abs(item.agg.amount) / totalForPercent
                    : item.agg.amount / totalForPercent
                }

                return ChartRow(
                    id: item.id.uuidString,
                    name: item.agg.name,
                    iconName: item.agg.icon,
                    colorKey: item.agg.colorKey,
                    amount: item.agg.amount,
                    percent: pct
                )
            }
            .sorted { lhs, rhs in
                // Descending: expense/income by amount, balance by absolute
                if tab == .balance {
                    return abs(lhs.amount) > abs(rhs.amount)
                } else {
                    return lhs.amount > rhs.amount
                }
            }

        // 5) summary
        let txCount = inMonth.count
        let totalAmount: Double
        switch tab {
        case .income:
            totalAmount = rows.reduce(0) { $0 + $1.amount }
        case .expense:
            totalAmount = rows.reduce(0) { $0 + $1.amount }
        case .balance:
            totalAmount = inMonth.reduce(0) { $0 + ($1.type == .income ? $1.amount : -$1.amount) }
        }

        output = ChartsOutput(rows: rows, transactionCount: txCount, totalAmount: totalAmount)
    }
}

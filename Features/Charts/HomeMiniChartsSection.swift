//
//  HomeMiniChartsSection.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct HomeMiniChartsSection: View {
    let allTransactions: [Transaction]
    let monthAnchor: Date
    let tab: HomeView.HomeTab
    let currencyCode: String
    let onOpenCharts: () -> Void

    private var monthTx: [Transaction] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: monthAnchor))!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return allTransactions.filter { $0.date >= start && $0.date < end }
    }

    private var incomeSum: Double {
        monthTx.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var expenseSum: Double {
        monthTx.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var balanceSum: Double { incomeSum - expenseSum }

    var body: some View {
        // ύψος “mini” για να ταιριάζει με το reference
        VStack(spacing: 10) {
            HStack {
                Text("Charts")
                    .font(.headline)
                Spacer()
                
                Button(action: onOpenCharts) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                        .background(.thinMaterial, in: Circle())
                }
                .accessibilityLabel("Open charts")
                
                //Button("Open") { onOpenCharts() }
                    //.font(.subheadline)
            }

            // Mini content ανά tab (Month-only)
            switch tab {
            case .income:
                MiniOneLineStat(title: "Total income", value: incomeSum, currencyCode: currencyCode)

            case .expense:
                MiniOneLineStat(title: "Total expense", value: expenseSum, currencyCode: currencyCode)

            case .balance:
                VStack(spacing: 6) {
                    MiniOneLineStat(title: "Income", value: incomeSum, currencyCode: currencyCode)
                    MiniOneLineStat(title: "Expense", value: expenseSum, currencyCode: currencyCode)
                    MiniOneLineStat(title: "Balance", value: balanceSum, currencyCode: currencyCode)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

private struct MiniOneLineStat: View {
    let title: String
    let value: Double
    let currencyCode: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value, format: .currency(code: currencyCode))
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}

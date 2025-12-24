//
//  ChartsView.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI
import SwiftData

struct ChartsView: View {
    let monthAnchor: Date
    let tab: HomeView.HomeTab

    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @StateObject private var vm = ChartsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Rows (like the Android reference)
                VStack(spacing: 10) {
                    ForEach(vm.output.rows) { row in
                        ChartRowView(
                            row: row,
                            tab: tab
                        )
                        Divider().opacity(0.6)
                    }
                }
                .padding(.top, 8)

                // Summary (Number of transactions + total)
                VStack(spacing: 0) {
                    SummaryRow(title: "Number of transactions", value: "\(vm.output.transactionCount)")
                    Divider()
                    SummaryRow(title: summaryTitle(for: tab), value: money(vm.output.totalAmount))
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Charts")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { rebuild() }
        .onChange(of: monthAnchor) { _, _ in rebuild() }
        .onChange(of: tab) { _, _ in rebuild() }
    }

    private func rebuild() {
        vm.build(for: tab, transactions: allTransactions, monthAnchor: monthAnchor)
    }

    private func summaryTitle(for tab: HomeView.HomeTab) -> String {
        switch tab {
        case .income: return "Total income amount"
        case .expense: return "Total expense amount"
        case .balance: return "Balance"
        }
    }

    private func money(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = allTransactions.first?.currencyCode ?? "EUR"
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

private struct ChartRowView: View {
    let row: ChartRow
    let tab: HomeView.HomeTab

    var body: some View {
        HStack(spacing: 12) {
            // Left icon + title
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(SemanticColor.color(for: row.colorKey).opacity(0.18))
                        .frame(width: 44, height: 44)

                    Image(systemName: row.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SemanticColor.color(for: row.colorKey))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(row.name)
                        .font(.system(size: 16, weight: .semibold))

                    Text(percentText(row.percent))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 10)

            // Right bar + amount (reference style)
            VStack(alignment: .trailing, spacing: 6) {
                Bar(percent: row.percent, color: SemanticColor.color(for: row.colorKey))

                Text(amountText(row.amount, tab: tab))
                    .font(.callout)
                    .foregroundStyle(amountColor(for: tab, value: row.amount))
            }
            .frame(width: 170)
        }
        .padding(.vertical, 6)
    }

    private func percentText(_ p: Double) -> String {
        String(format: "%.1f%%", p * 100)
    }

    private func amountText(_ value: Double, tab: HomeView.HomeTab) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        let text = f.string(from: NSNumber(value: value)) ?? "\(value)"

        // Για balance, αν είναι αρνητικό να φαίνεται “-€…”
        return text
    }

    private func amountColor(for tab: HomeView.HomeTab, value: Double) -> Color {
        switch tab {
        case .income:
            return .green
        case .expense:
            return .red
        case .balance:
            return value >= 0 ? .green : .red
        }
    }
}

private struct Bar: View {
    let percent: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.secondary.opacity(0.12))

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                    .frame(width: max(8, geo.size.width * percent))
            }
        }
        .frame(height: 16)
    }
}

private struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

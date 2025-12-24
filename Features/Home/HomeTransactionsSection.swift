//
//  HomeTransactionsSection.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct HomeTransactionsSection: View {
    let headerTitle: String
    let transactions: [Transaction]
    let dayBalanceTitle: String
    let dayBalanceValue: Double
    let currencyCode: String
    let onTapTransaction: (Transaction) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "list.bullet")
                Text(headerTitle).font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.thinMaterial)

            LazyVStack(spacing: 0) {
                ForEach(transactions) { tx in
                    Button {
                        onTapTransaction(tx)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(tx.category.name)
                                    .font(.headline)

                                Spacer()

                                Text(MoneyFormatter.format(tx.amount, currency: tx.currencyCode))
                                    .font(.headline)
                                    .foregroundStyle(tx.type == .income ? .green : .red)
                            }

                            Text("Note: \(tx.note?.isEmpty == false ? tx.note! : "No additional note")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)

                    Divider().padding(.leading, 16)
                }

                // Day balance row
                HStack {
                    Text(dayBalanceTitle).font(.headline)
                    Spacer()
                    Text(MoneyFormatter.format(dayBalanceValue, currency: currencyCode))
                        .font(.headline)
                        .foregroundStyle(dayBalanceValue >= 0 ? .green : .red)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.thinMaterial)
            }
        }
    }
}

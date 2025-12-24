//
//  HomeTopTabsBar.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct HomeTopTabsBar<Tab: CaseIterable & Identifiable & Equatable>: View where Tab.AllCases: RandomAccessCollection {
    @Binding var tab: Tab
    var onSelect: () -> Void = { }

    /// Provide label text via this closure.
    var title: (Tab) -> String

    /// Optional second line text (e.g. totals). If nil -> no second line.
    var subtitle: ((Tab) -> String?)? = nil

    init(
        tab: Binding<Tab>,
        onSelect: @escaping () -> Void = { },
        title: @escaping (Tab) -> String,
        subtitle: ((Tab) -> String?)? = nil
    ) {
        self._tab = tab
        self.onSelect = onSelect
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(Tab.allCases)) { t in
                Button {
                    tab = t
                    onSelect()
                } label: {
                    VStack(spacing: 6) {
                        Text(title(t))
                            .font(.headline)
                            .foregroundStyle(t == tab ? .primary : .secondary)

                        if let subtitle, let line = subtitle(t) {
                            Text(line)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(t == tab ? .primary : .secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }

                        Rectangle()
                            .frame(height: 3)
                            .opacity(t == tab ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, subtitle == nil ? 12 : 10)
                }
            }
        }
        .background(.thinMaterial)
    }
}

// MARK: - Convenience for HomeView.HomeTab
extension HomeTopTabsBar where Tab == HomeView.HomeTab {
    init(
        tab: Binding<HomeView.HomeTab>,
        stats: TransactionStats,
        currencyCode: String,
        onSelect: @escaping () -> Void = { }
    ) {
        self.init(
            tab: tab,
            onSelect: onSelect,
            title: { $0.rawValue },
            subtitle: { t in
                switch t {
                case .income:
                    return MoneyFormatter.format(stats.incomeTotal, currency: currencyCode)
                case .balance:
                    return MoneyFormatter.format(stats.balance, currency: currencyCode)
                case .expense:
                    return MoneyFormatter.format(stats.expenseTotal, currency: currencyCode)
                }
            }
        )
    }
}


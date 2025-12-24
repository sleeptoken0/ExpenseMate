//
//  HomeView.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @Query private var settingsRows: [AppSettings]

    private var settings: AppSettings {
        settingsRows.first ?? AppSettings()
    }

    private var weekStart: WeekStart {
        settings.weekStartsOnMonday ? .monday : .sunday
    }

    @State private var tab: HomeTab = .balance
    @State private var monthAnchor: Date = .now
    @State private var selectedDate: Date = .now
    @State private var isAddExpanded: Bool = false
    @State private var route: Route?

    enum HomeTab: String, CaseIterable, Identifiable {
        case income = "Income"
        case balance = "Balance"
        case expense = "Expense"
        var id: String { rawValue }

        var typeFilter: TransactionType? {
            switch self {
            case .income: return .income
            case .expense: return .expense
            case .balance: return nil
            }
        }
    }

    enum Route: Identifiable {
        case addIncome(date: Date)
        case addExpense(date: Date)
        case edit(tx: Transaction)
        case settings
        case charts
        case calendarDay(date: Date)

        var id: String {
            switch self {
            case .addIncome: return "addIncome"
            case .addExpense: return "addExpense"
            case .edit(let tx): return "edit-\(tx.persistentModelID)"
            case .settings: return "settings"
            case .charts: return "charts"
            case .calendarDay(let date): return "day-\(date.timeIntervalSince1970)"
            }
        }
    }

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {

                    Section {
                        // MARK: Mini charts (NOT sticky)
                        HomeMiniChartsSection(
                            allTransactions: allTransactions,
                            monthAnchor: monthAnchor,
                            tab: tab,
                            currencyCode: monthCurrencyCode,
                            onOpenCharts: {
                                isAddExpanded = false
                                route = .charts
                            }
                        )
                        .padding(.top, 6)
                        .padding(.bottom, 10)

                        // MARK: Calendar grid
                        CalendarMonthGridView(
                            monthAnchor: $monthAnchor,
                            selectedDate: $selectedDate,
                            dayMarkers: monthDayMarkers,
                            weekStart: weekStart,
                            autoSwitchMonthOnOutOfMonthTap: true,
                            onTapDay: { date in
                                selectedDate = date
                                isAddExpanded = false
                                route = .calendarDay(date: date)
                            }
                        )
                        .padding(.top, 10)

                        // MARK: Transactions
                        HomeTransactionsSection(
                            headerTitle: headerTitleForSelectedDate,
                            transactions: transactionsForSelectedDay,
                            dayBalanceTitle: dayBalanceTitle,
                            dayBalanceValue: dayBalanceValue,
                            currencyCode: defaultCurrencyCode,
                            onTapTransaction: { tx in
                                isAddExpanded = false
                                route = .edit(tx: tx)
                            }
                        )
                    } header: {
                        HomeTopTabsBar(
                            tab: $tab,
                            stats: monthStats,
                            currencyCode: monthCurrencyCode,
                            onSelect: { isAddExpanded = false }
                        )
                        .background(.ultraThinMaterial) // να “γράφει” πάνω από content
                        .zIndex(10)
                    }
                }
            }

            // MARK: Floating buttons
            HomeFloatingButtonsOverlay(
                isAddExpanded: $isAddExpanded,
                onAddIncome: { route = .addIncome(date: selectedDate) },
                onAddExpense: { route = .addExpense(date: selectedDate) },
                onOpenSettings: {
                    isAddExpanded = false
                    route = .settings
                }
            )
        }
        .sheet(item: $route) { route in
            switch route {
            case .addIncome(let date):
                NavigationStack { TransactionEditorView(mode: .addIncome(initialDate: date)) }
            case .addExpense(let date):
                NavigationStack { TransactionEditorView(mode: .addExpense(initialDate: date)) }
            case .edit(let tx):
                NavigationStack { TransactionEditorView(mode: .edit(transaction: tx)) }
            case .calendarDay(let date):
                NavigationStack { CalendarDayView(date: date) }
            case .settings:
                NavigationStack { SettingsView() }
            case .charts:
                NavigationStack { ChartsView(monthAnchor: monthAnchor, tab: tab) }
            }
        }

    }

    // MARK: - Derived (Day)

    private var headerTitleForSelectedDate: String {
        isSameDay(selectedDate, .now) ? "Today's transactions" : "Transactions"
    }

    private var dayBalanceTitle: String {
        isSameDay(selectedDate, .now) ? "Today's balance" : "Day balance"
    }

    private var defaultCurrencyCode: String {
        transactionsForSelectedDay.first?.currencyCode ?? settings.defaultCurrencyCode
    }

    private var transactionsForSelectedDay: [Transaction] {
        let day = allTransactions.filter { isSameDay($0.date, selectedDate) }

        if let filter = tab.typeFilter {
            return day.filter { $0.type == filter }
        } else {
            return day
        }
    }

    private var dayBalanceValue: Double {
        let day = allTransactions.filter { isSameDay($0.date, selectedDate) }
        let income = day.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = day.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return income - expense
    }

    // MARK: - Derived (Month markers)

    private var monthDayMarkers: [Date: DayMarker] {
        let range = monthDateRange(monthAnchor)
        let monthTx = allTransactions.filter { $0.date >= range.start && $0.date < range.end }

        var map: [Date: DayMarker] = [:]
        for tx in monthTx {
            let key = startOfDay(tx.date)
            var marker = map[key] ?? DayMarker(hasIncome: false, hasExpense: false)
            if tx.type == .income { marker.hasIncome = true }
            if tx.type == .expense { marker.hasExpense = true }
            map[key] = marker
        }
        return map
    }

    // MARK: - Month stats for totals in tabs
    private var monthRange: DateRange {
        DateRange.month(containing: monthAnchor)
    }

    private var monthStats: TransactionStats {
        TransactionStats.compute(transactions: allTransactions, in: monthRange)
    }

    private var monthCurrencyCode: String {
        let monthTx = allTransactions.filter { monthRange.contains($0.date) }
        return monthTx.first?.currencyCode ?? settings.defaultCurrencyCode
    }

    // MARK: - Helpers

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    private func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }

    private func monthDateRange(_ anchor: Date) -> (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: anchor))!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return (start, end)
    }
}

extension Calendar {
    func monthRange(containing date: Date) -> (start: Date, end: Date) {
        let start = self.date(from: dateComponents([.year, .month], from: date))!
        let end = self.date(byAdding: DateComponents(month: 1), to: start)!
        return (start, end)
    }
}


#Preview {
    NavigationStack { HomeView() }
        .modelContainer(PreviewData.makeContainer())
}

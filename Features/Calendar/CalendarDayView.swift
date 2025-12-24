//
//  CalendarDayView.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI
import SwiftData

struct CalendarDayView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @State private var date: Date
    @State private var isAddExpanded: Bool = false
    @State private var route: Route?

    enum Route: Identifiable {
        case addIncome(date: Date)
        case addExpense(date: Date)
        case edit(tx: Transaction)

        var id: String {
            switch self {
            case .addIncome: return "addIncome"
            case .addExpense: return "addExpense"
            case .edit(let tx): return "edit-\(tx.persistentModelID)"
            }
        }
    }

    init(date: Date) {
        _date = State(initialValue: date)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                listSection
            }

            // Full-screen dim (IMPORTANT: not inside the dock)
            if isAddExpanded {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring()) { isAddExpanded = false } }
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            DayNavigatorBar(
                leftTitle: shortDateLabel(prevDay),
                rightTitle: shortDateLabel(nextDay),
                onPrev: { shiftDay(-1) },
                onNext: { shiftDay(1) }
            ) {
                FloatingActionMenu(
                    isExpanded: $isAddExpanded,
                    mainSystemImage: isAddExpanded ? "arrow.uturn.left" : "plus",
                    mainTint: .yellow,
                    actions: [
                        .init(title: "Add Income", systemImage: "plus", tint: .green) {
                            route = .addIncome(date: date)
                        },
                        .init(title: "Add Expense", systemImage: "minus", tint: .red) {
                            route = .addExpense(date: date)
                        }
                    ],
                    placement: .dockedCenter,
                    materialPills: true,
                    showsDimmingBackground: false // parent draws dim
                )
                .padding(.bottom, 6) // tiny lift like the reference (tweak if needed)
            }
        }
        .sheet(item: $route) { route in
            switch route {
            case .addIncome(let d):
                NavigationStack { TransactionEditorView(mode: .addIncome(initialDate: d)) }
            case .addExpense(let d):
                NavigationStack { TransactionEditorView(mode: .addExpense(initialDate: d)) }
            case .edit(let tx):
                NavigationStack { TransactionEditorView(mode: .edit(transaction: tx)) }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedWeekday(date))
                        .font(.title3.weight(.semibold))
                    Text(formattedFullDate(date))
                        .font(.title3.weight(.semibold))
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                        .background(.thinMaterial, in: Circle())
                }
                .accessibilityLabel("Back")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            HStack(spacing: 10) {
                Image(systemName: "list.bullet")
                Text("Transactions")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.thinMaterial)
        }
    }

    // MARK: - List

    private var listSection: some View {
        List {
            ForEach(transactionsForDay) { tx in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(tx.category.name)
                                .font(.headline)

                            Spacer()

                            Text(formattedMoney(tx.amount, tx.currencyCode))
                                .font(.headline)
                                .foregroundStyle(tx.type == .income ? .green : .red)
                        }

                        if let note = tx.note, !note.isEmpty {
                            Text("Note: \(note)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Note: No additional note")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 0)

                    Button {
                        isAddExpanded = false
                        route = .edit(tx: tx)
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit")
                }
                .padding(.vertical, 6)
            }

            Section {
                HStack {
                    Text("Day balance")
                        .font(.headline)
                    Spacer()
                    Text(formattedMoney(dayBalance, currencyForDay))
                        .font(.headline)
                        .foregroundStyle(dayBalance >= 0 ? .green : .red)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Derived data

    private var transactionsForDay: [Transaction] {
        allTransactions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private var dayBalance: Double {
        let income = transactionsForDay.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = transactionsForDay.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return income - expense
    }

    private var currencyForDay: String {
        transactionsForDay.first?.currencyCode ?? "EUR"
    }

    private var prevDay: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
    }

    private var nextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
    }

    // MARK: - Helpers

    private func shiftDay(_ delta: Int) {
        withAnimation(.spring()) {
            isAddExpanded = false
            if let new = Calendar.current.date(byAdding: .day, value: delta, to: date) {
                date = new
            }
        }
    }

    private func formattedWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE,"
        return f.string(from: date)
    }

    private func formattedFullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d yyyy"
        return f.string(from: date)
    }

    private func shortDateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private func formattedMoney(_ amount: Double, _ currency: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currency
        return f.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

#Preview {
    NavigationStack {
        CalendarDayView(date: .now)
    }
    .modelContainer(PreviewData.makeContainer())
}

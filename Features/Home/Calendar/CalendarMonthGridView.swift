//
//  CalendarMonthGridView.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct CalendarMonthGridView: View {
    @Binding var monthAnchor: Date
    @Binding var selectedDate: Date

    let dayMarkers: [Date: DayMarker]

    /// Controls whether week starts on Sunday or Monday.
    let weekStart: WeekStart

    /// If true, tapping an out-of-month day auto-navigates to that month before opening day view.
    let autoSwitchMonthOnOutOfMonthTap: Bool

    let onTapDay: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 10) {
            header
            weekdayHeader

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysForGrid(), id: \.self) { day in
                    let key = displayCalendar.startOfDay(for: day)

                    DayCellView(
                        date: day,
                        selectedDate: selectedDate,
                        inMonth: isSameMonth(day, monthAnchor),
                        marker: dayMarkers[key],
                        calendar: displayCalendar
                    ) {
                        handleTap(on: day)
                    }
                }

            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 40, height: 40)
                    .background(.thinMaterial, in: Circle())
            }

            Spacer()

            Text(monthShortTitle(monthAnchor))
                .font(.headline)

            Spacer()

            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .frame(width: 40, height: 40)
                    .background(.thinMaterial, in: Circle())
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Weekday header

    private var weekdayHeader: some View {
        // Calendar.shortWeekdaySymbols is locale-aware but always starts at Sunday.
        let symbols = displayCalendar.shortWeekdaySymbols
        let ordered = reorderWeekdaySymbols(symbols, weekStart: weekStart)

        return HStack {
            ForEach(ordered, id: \.self) { s in
                Text(s.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Grid generation

    private func daysForGrid() -> [Date] {
        let cal = displayCalendar
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: monthAnchor))!
        let daysInMonth = cal.range(of: .day, in: .month, for: startOfMonth)!.count

        // weekday: 1..7 where 1 = Sunday
        let firstWeekday = cal.component(.weekday, from: startOfMonth)

        // Convert to a 0-based index aligned to weekStart:
        // If week starts Sunday: leading = firstWeekday - 1
        // If week starts Monday: leading = (firstWeekday + 5) % 7
        let leading: Int = {
            switch weekStart {
            case .sunday:
                return firstWeekday - 1
            case .monday:
                return (firstWeekday + 5) % 7
            }
        }()

        var days: [Date] = []

        // leading days from previous month
        if leading > 0 {
            for i in 0..<leading {
                days.append(cal.date(byAdding: .day, value: i - leading, to: startOfMonth)!)
            }
        }

        // current month days
        for d in 0..<daysInMonth {
            days.append(cal.date(byAdding: .day, value: d, to: startOfMonth)!)
        }

        // trailing days to complete weeks
        while days.count % 7 != 0 {
            let last = days.last!
            days.append(cal.date(byAdding: .day, value: 1, to: last)!)
        }

        return days
    }

    // MARK: - Tap behavior

    private func handleTap(on day: Date) {
        let tappedIsInMonth = isSameMonth(day, monthAnchor)

        if !tappedIsInMonth, autoSwitchMonthOnOutOfMonthTap {
            // jump anchor to tapped day’s month
            withAnimation(.spring()) {
                monthAnchor = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: day)) ?? day
            }
        }

        selectedDate = day
        onTapDay(day)
    }

    // MARK: - Month navigation

    private func shiftMonth(_ delta: Int) {
        if let new = Calendar.current.date(byAdding: .month, value: delta, to: monthAnchor) {
            monthAnchor = new
        }
    }

    // MARK: - Helpers

    private func monthShortTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: date)
    }

    private func isSameMonth(_ a: Date, _ anchor: Date) -> Bool {
        let cal = Calendar.current
        return cal.component(.month, from: a) == cal.component(.month, from: anchor)
            && cal.component(.year, from: a) == cal.component(.year, from: anchor)
    }

    private func reorderWeekdaySymbols(_ symbols: [String], weekStart: WeekStart) -> [String] {
        switch weekStart {
        case .sunday:
            return symbols
        case .monday:
            // Move Sunday (index 0) to the end => Mon..Sun
            guard symbols.count == 7 else { return symbols }
            return Array(symbols.dropFirst()) + [symbols.first!]
        }
    }
    
    private var displayCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = weekStart.rawValue // 1=Sun, 2=Mon
        return cal
    }

}

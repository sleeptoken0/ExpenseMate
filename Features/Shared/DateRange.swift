//
//  DateRange.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation

struct DateRange: Equatable {
    let start: Date   // inclusive
    let end: Date     // exclusive

    func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }

    // MARK: - Factory

    static func day(containing date: Date, calendar: Calendar = .current) -> DateRange {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return DateRange(start: start, end: end)
    }

    static func month(containing anchor: Date, calendar: Calendar = .current) -> DateRange {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: anchor))!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return DateRange(start: start, end: end)
    }

    static func year(containing anchor: Date, calendar: Calendar = .current) -> DateRange {
        let start = calendar.date(from: calendar.dateComponents([.year], from: anchor))!
        let end = calendar.date(byAdding: .year, value: 1, to: start)!
        return DateRange(start: start, end: end)
    }

    static func week(containing anchor: Date, weekStartsOnMonday: Bool, calendar: Calendar = .current) -> DateRange {
        var cal = calendar
        cal.firstWeekday = weekStartsOnMonday ? 2 : 1 // 1=Sun, 2=Mon

        // startOfWeek based on firstWeekday
        let startOfDay = cal.startOfDay(for: anchor)
        let weekday = cal.component(.weekday, from: startOfDay)
        let delta = (weekday - cal.firstWeekday + 7) % 7
        let start = cal.date(byAdding: .day, value: -delta, to: startOfDay)!
        let end = cal.date(byAdding: .day, value: 7, to: start)!
        return DateRange(start: start, end: end)
    }
}

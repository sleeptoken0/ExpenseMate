//
//  AppSettings.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID

    var defaultCurrencyCode: String
    var defaultChartsPeriodRaw: String // Period.rawValue
    var weekStartsOnMonday: Bool

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        defaultCurrencyCode: String = "EUR",
        defaultChartsPeriod: Period = .month,
        weekStartsOnMonday: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.defaultCurrencyCode = defaultCurrencyCode
        self.defaultChartsPeriodRaw = defaultChartsPeriod.rawValue
        self.weekStartsOnMonday = weekStartsOnMonday
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var defaultChartsPeriod: Period {
        get { Period(rawValue: defaultChartsPeriodRaw) ?? .month }
        set { defaultChartsPeriodRaw = newValue.rawValue }
    }
}

//
//  SettingsStore.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation
import SwiftData

enum SettingsStore {
    static func fetchOrCreate(_ context: ModelContext) throws -> AppSettings {
        let descriptor = FetchDescriptor<AppSettings>(
            predicate: #Predicate { _ in true }
        )
        let results = try context.fetch(descriptor)

        if let existing = results.first {
            return existing
        }

        let new = AppSettings(
            defaultCurrencyCode: "EUR",
            defaultChartsPeriod: .month,
            weekStartsOnMonday: true
        )
        context.insert(new)
        try context.save()
        return new
    }
}



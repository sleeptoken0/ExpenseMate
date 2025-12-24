//
//  SeedData.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation
import SwiftData

enum SeedData {
    static func seedIfNeeded(_ context: ModelContext) throws {
        try seedSettingsIfNeeded(context)
        try seedCategoriesIfNeeded(context)
        try context.save()
    }

    // MARK: - Settings

    private static func seedSettingsIfNeeded(_ context: ModelContext) throws {
        let descriptor = FetchDescriptor<AppSettings>(
            predicate: #Predicate { _ in true }
        )
        let existing = try context.fetch(descriptor)
        guard existing.isEmpty else { return }

        let settings = AppSettings(
            defaultCurrencyCode: "EUR",
            defaultChartsPeriod: .month,
            weekStartsOnMonday: true
        )
        context.insert(settings)
    }

    // MARK: - Categories

    private static func seedCategoriesIfNeeded(_ context: ModelContext) throws {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { _ in true }
        )
        let existing = try context.fetch(descriptor)
        guard existing.isEmpty else { return }

        // Income categories
        let income: [(name: String, icon: String, colorKey: String)] = [
            ("Salary", "banknote", "incomeGreen"),
            ("Deposit", "arrow.down.circle", "incomeGreen"),
            ("Savings", "tray.full", "incomeGreen")
        ]

        // Expense categories
        let expense: [(name: String, icon: String, colorKey: String)] = [
            ("Food", "fork.knife", "expenseGreen"),
            ("Bills", "doc.text", "expenseRed"),
            ("Clothes", "tshirt.fill", "expenseOrange"),
            ("Entertainment", "gamecontroller", "expenseOlive"),
            ("Fuel", "fuelpump", "expenseGray"),
            ("General", "basket", "expenseBrown"),
            ("Gifts", "gift", "expensePink"),
            ("Health", "cross.case", "expenseRed"),
            ("Holidays", "airplane", "expenseBlue"),
            ("Home", "house", "expenseGray"),
            ("Kids", "figure.and.child.holdinghands", "expenseYellow"),
            ("Shopping", "bag", "expenseOrange"),
            ("Sports", "sportscourt", "expenseBlue")
        ]

        var order = 0

        for item in income {
            let c = Category(
                name: item.name,
                type: .income,
                iconName: item.icon,
                colorKey: item.colorKey,
                sortOrder: order,
                isActive: true
            )
            context.insert(c)
            order += 1
        }

        for item in expense {
            let c = Category(
                name: item.name,
                type: .expense,
                iconName: item.icon,
                colorKey: item.colorKey,
                sortOrder: order,
                isActive: true
            )
            context.insert(c)
            order += 1
        }
    }
}


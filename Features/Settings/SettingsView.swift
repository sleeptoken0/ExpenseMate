//
//  SettingsView.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var settings: AppSettings?
    @State private var weekStart: WeekStart = .monday
    @State private var currencyCode: String = "EUR"

    @State private var loadErrorMessage: String?

    var body: some View {
        Form {
            if let msg = loadErrorMessage {
                Section {
                    Text(msg).foregroundStyle(.red)
                }
            }

            Section("Calendar") {
                Picker("Week starts on", selection: $weekStart) {
                    ForEach(WeekStart.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.inline)

                Text("This changes the weekday header and month alignment in the calendar grid.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Currency") {
                TextField("Default currency code", text: $currencyCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .onChange(of: currencyCode) { _, newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                        currencyCode = String(trimmed.prefix(3))
                    }

                Text("Use ISO code like EUR, USD, GBP.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadSettings() }
        .onChange(of: weekStart) { _, _ in persistWeekStart() }
        .onChange(of: currencyCode) { _, _ in persistCurrency() }
    }

    private func loadSettings() {
        do {
            let s = try SettingsStore.fetchOrCreate(modelContext)
            settings = s
            weekStart = s.weekStartsOnMonday ? .monday : .sunday
            currencyCode = s.defaultCurrencyCode
            loadErrorMessage = nil
        } catch {
            loadErrorMessage = "Failed to load settings: \(error.localizedDescription)"
        }
    }

    private func persistWeekStart() {
        guard let s = settings else { return }
        s.weekStartsOnMonday = (weekStart == .monday)
        s.updatedAt = .now
        try? modelContext.save()
    }

    private func persistCurrency() {
        guard let s = settings else { return }

        let trimmed = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if trimmed.isEmpty { currencyCode = s.defaultCurrencyCode; return }

        currencyCode = String(trimmed.prefix(3))
        s.defaultCurrencyCode = currencyCode
        s.updatedAt = .now
        try? modelContext.save()
    }
}

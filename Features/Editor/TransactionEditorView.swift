//
//  TransactionEditorView.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI
import SwiftData

enum EditorMode: Equatable {
    case addIncome(initialDate: Date)
    case addExpense(initialDate: Date)
    case edit(transaction: Transaction)
}

struct TransactionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Category> { $0.typeRaw == "income" && $0.isActive == true },
           sort: \Category.sortOrder)
    private var incomeCategories: [Category]

    @Query(filter: #Predicate<Category> { $0.typeRaw == "expense" && $0.isActive == true },
           sort: \Category.sortOrder)
    private var expenseCategories: [Category]

    let mode: EditorMode

    // Draft fields (UI state)
    @State private var amountText: String = ""
    @State private var selectedCategoryID: PersistentIdentifier?
    @State private var date: Date = Date()
    @State private var note: String = ""

    @State private var isShowingDatePicker: Bool = false
    @State private var isShowingPhotoActions: Bool = false

    @State private var currencyCode: String = "EUR"
    @State private var didHydrate = false

    private var transactionType: TransactionType {
        switch mode {
        case .addIncome: return .income
        case .addExpense: return .expense
        case .edit(let tx): return tx.type
        }
    }

    private var categoriesForMode: [Category] {
        transactionType == .income ? incomeCategories : expenseCategories
    }

    private var selectedCategory: Category? {
        guard let id = selectedCategoryID else { return nil }
        return categoriesForMode.first { $0.persistentModelID == id }
    }

    private var title: String {
        switch mode {
        case .addIncome: return "Add Income"
        case .addExpense: return "Add Expense"
        case .edit: return "Edit Transaction"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Form {
                amountSection
                categorySection
                noteSection
                infoHintSection
            }
            .scrollContentBackground(.hidden)

            bottomBar
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { isShowingDatePicker = true } label: { Image(systemName: "calendar") }
                Button { isShowingPhotoActions = true } label: { Image(systemName: "camera") }

                Button(role: .destructive) {
                    // later: delete in edit mode
                } label: {
                    Image(systemName: "trash")
                }
                .opacity(isEditMode ? 1 : 0)
                .disabled(!isEditMode)
            }
        }
        .onAppear { hydrateIfNeeded() }
        .onChange(of: categoriesForMode) { _, _ in
            // όταν φορτώσουν categories, βάλε default αν είμαστε σε add mode
            guard !isEditMode else { return }
            if selectedCategoryID == nil, let first = categoriesForMode.first {
                selectedCategoryID = first.persistentModelID
            }
        }
        .sheet(isPresented: $isShowingDatePicker) {
            NavigationStack {
                DatePicker("Select Date", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { isShowingDatePicker = false }
                        }
                    }
            }
        }
        .confirmationDialog("Add attachment",
                            isPresented: $isShowingPhotoActions,
                            titleVisibility: .visible) {
            Button("Capture photo (Camera)") { }
            Button("Choose from Photos") { }
            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - UI

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(formattedAmountPreview) \(currencyCode)")
                    .font(.system(size: 28, weight: .semibold))

                Spacer()

                Button { amountText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .opacity(amountText.isEmpty ? 0.3 : 1)
                }
                .disabled(amountText.isEmpty)
            }
            Divider()
        }
        .padding()
    }

    private var amountSection: some View {
        Section("Amount") {
            TextField("0.00", text: $amountText)
                .keyboardType(.decimalPad)
        }
    }

    private var categorySection: some View {
        Section("Category") {
            if categoriesForMode.isEmpty {
                Text("No categories available").foregroundStyle(.secondary)
            } else {
                Picker("Select", selection: $selectedCategoryID) {
                    ForEach(categoriesForMode) { category in
                        Text(category.name).tag(Optional.some(category.persistentModelID))
                    }
                }
            }
        }
    }

    private var noteSection: some View {
        Section("Note") {
            TextField("Optional note", text: $note, axis: .vertical)
                .lineLimit(3, reservesSpace: true)
        }
    }

    private var infoHintSection: some View {
        Section {
            Text("If you have repeating transactions you can set reminders in the settings section.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var bottomBar: some View {
        HStack {
            Button("Close") { dismiss() }
                .frame(maxWidth: .infinity)

            Divider()

            Button("Save") { save() }
                .frame(maxWidth: .infinity)
                .disabled(!canSave)
        }
        .frame(height: 56)
        .background(.thinMaterial)
    }

    // MARK: - Logic

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var canSave: Bool {
        parseAmount() != nil && selectedCategory != nil
    }

    private var formattedAmountPreview: String {
        if let value = parseAmount(), value > 0 { return String(format: "%.2f", value) }
        return "0.00"
    }

    private func parseAmount() -> Double? {
        let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func hydrateIfNeeded() {
        guard !didHydrate else { return }
        didHydrate = true

        // Currency from settings
        do {
            let settings = try SettingsStore.fetchOrCreate(modelContext)
            currencyCode = settings.defaultCurrencyCode
        } catch {
            print("Settings fetch failed:", error)
            currencyCode = "EUR"
        }

        switch mode {
        case .addIncome(let initialDate),
             .addExpense(let initialDate):
            date = initialDate
            // default category θα μπει και από onChange όταν φορτώσουν

        case .edit(let tx):
            amountText = String(format: "%.2f", tx.amount)
            date = tx.date
            note = tx.note ?? ""
            currencyCode = tx.currencyCode
            selectedCategoryID = tx.category.persistentModelID
        }
    }

    private func save() {
        guard let amount = parseAmount(),
              let category = selectedCategory
        else { return }

        let now = Date()

        switch mode {
        case .addIncome, .addExpense:
            let tx = Transaction(
                type: transactionType,
                amount: amount,
                currencyCode: currencyCode,
                date: date,
                note: note.isEmpty ? nil : note,
                category: category,
                attachment: nil,
                createdAt: now,
                updatedAt: now
            )
            modelContext.insert(tx)

        case .edit(let existing):
            existing.amount = amount
            existing.currencyCode = currencyCode
            existing.date = date
            existing.note = note.isEmpty ? nil : note
            existing.category = category
            existing.updatedAt = now
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Save failed:", error)
        }
    }
}


#Preview("Add Income") {
    NavigationStack {
        TransactionEditorView(mode: .addIncome(initialDate: .now))
    }
    .modelContainer(PreviewData.makeContainer())
}

#Preview("Add Expense") {
    NavigationStack {
        TransactionEditorView(mode: .addExpense(initialDate: .now))
    }
    .modelContainer(PreviewData.makeContainer())
}

#Preview("Edit") {
    let container = PreviewData.makeContainer()
    let context = ModelContext(container)

    let incomeCategory = (try? context.fetch(FetchDescriptor<Category>(
        predicate: #Predicate { $0.typeRaw == "income" && $0.isActive == true },
        sortBy: [SortDescriptor(\.sortOrder)]
    )))?.first

    let tx = Transaction(
        type: .income,
        amount: 75,
        currencyCode: "EUR",
        date: .now,
        note: "work",
        category: incomeCategory!,
        attachment: nil,
        createdAt: .now,
        updatedAt: .now
    )
    context.insert(tx)
    try? context.save()

    return NavigationStack {
        TransactionEditorView(mode: .edit(transaction: tx))
    }
    .modelContainer(container)
}

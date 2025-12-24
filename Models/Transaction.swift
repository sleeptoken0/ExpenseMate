//
//  Transaction.swift
//  ExpenseMate
//
//  Created by Alex Senu on 22/12/25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID

    var typeRaw: String              // TransactionType.rawValue
    var amount: Double
    var currencyCode: String
    var date: Date                   // date+time; grouping by startOfDay

    var note: String?

    var createdAt: Date
    var updatedAt: Date

    // Relationships
    var category: Category
    var attachment: Attachment?      // only used for transaction extra details

    init(
        id: UUID = UUID(),
        type: TransactionType,
        amount: Double,
        currencyCode: String,
        date: Date,
        note: String? = nil,
        category: Category,
        attachment: Attachment? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.amount = amount
        self.currencyCode = currencyCode
        self.date = date
        self.note = note
        self.category = category
        self.attachment = attachment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }
}

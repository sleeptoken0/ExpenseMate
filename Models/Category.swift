//
//  Category.swift
//  ExpenseMate
//
//  Created by Alex Senu

import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String          // TransactionType.rawValue
    var iconName: String         // SF Symbol name or asset key
    var colorKey: String         // semantic color key
    var sortOrder: Int
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        type: TransactionType,
        iconName: String,
        colorKey: String,
        sortOrder: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.typeRaw = type.rawValue
        self.iconName = iconName
        self.colorKey = colorKey
        self.sortOrder = sortOrder
        self.isActive = isActive
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }
}



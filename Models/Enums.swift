//
//  Enums.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
}

enum Period: String, Codable, CaseIterable {
    case customDay
    case week
    case month
    case year
}

enum AttachmentKind: String, Codable, CaseIterable {
    case photo
}

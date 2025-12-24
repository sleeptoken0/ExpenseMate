//
//  Untitled.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation

struct ChartRow: Identifiable, Hashable {
    let id: String                 // categoryId string
    let name: String
    let iconName: String           // SF Symbol
    let colorKey: String           // semantic key
    let amount: Double
    let percent: Double            // 0...1
}

struct ChartsOutput: Equatable {
    let rows: [ChartRow]
    let transactionCount: Int
    let totalAmount: Double
}

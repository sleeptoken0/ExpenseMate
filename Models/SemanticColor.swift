//
//  SemanticColor.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

enum SemanticColor {
    static func color(for key: String) -> Color {
        switch key.lowercased() {
        case "income", "green": return .green
        case "expense", "red": return .red
        case "balance", "orange": return .orange
        case "food": return .green
        case "clothes": return .orange
        case "general": return .brown
        case "entertainment": return Color(red: 0.55, green: 0.65, blue: 0.20) // olive-ish
        case "today": return .yellow.opacity(0.6)
        default: return .blue
        }
    }
}

// μικρό fallback γιατί δεν υπάρχει default olive:
private extension Color {
    static var oliveFallback: Color { Color(red: 0.55, green: 0.65, blue: 0.20) }
}

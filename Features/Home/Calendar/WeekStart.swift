//
//  WeekStart.swift
//  ExpenseMate
//
//  Created by Alex Senu on 23/12/25.
//

import Foundation

enum WeekStart: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        }
    }
}

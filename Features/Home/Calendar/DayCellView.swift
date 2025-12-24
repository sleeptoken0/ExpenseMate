//
//  DayCellView.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct DayCellView: View {
    let date: Date
    let selectedDate: Date
    let inMonth: Bool
    let marker: DayMarker?
    let calendar: Calendar
    let onTap: () -> Void

    var body: some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dayNumber = calendar.component(.day, from: date)

        Button(action: onTap) {
            VStack(spacing: 6) {
                Text("\(dayNumber)")
                    .font(.subheadline.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(inMonth ? .primary : .secondary)

                HStack(spacing: 4) {
                    if marker?.hasIncome == true {
                        Capsule().fill(Color.green).frame(width: 12, height: 4)
                    }
                    if marker?.hasExpense == true {
                        Capsule().fill(Color.red).frame(width: 12, height: 4)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 6)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10).fill(Color.yellow.opacity(0.35))
                } else if isToday {
                    RoundedRectangle(cornerRadius: 10).strokeBorder(Color.yellow.opacity(0.6), lineWidth: 1.5)
                } else {
                    RoundedRectangle(cornerRadius: 10).fill(Color.clear)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

//
//  HomeFloatingButtonsOverlay.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct HomeFloatingButtonsOverlay: View {
    @Binding var isAddExpanded: Bool

    let onAddIncome: () -> Void
    let onAddExpense: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            FloatingActionMenu(
                isExpanded: $isAddExpanded,
                mainSystemImage: isAddExpanded ? "arrow.uturn.left" : "plus",
                mainTint: .yellow,
                actions: [
                    .init(title: "Add Income", systemImage: "plus", tint: .green, handler: onAddIncome),
                    .init(title: "Add Expense", systemImage: "minus", tint: .red, handler: onAddExpense)
                ]
            )

            VStack {
                Spacer()
                HStack {
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 64, height: 64)
                            .background(.gray.opacity(0.85), in: Circle())
                            .foregroundColor(.white)
                            .shadow(radius: 10, y: 5)
                    }
                    .padding(.leading, 18)
                    .padding(.bottom, 18)

                    Spacer()
                }
            }
        }
    }
}



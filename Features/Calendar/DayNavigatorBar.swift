//
//  DayNavigatorBar.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct DayNavigatorBar<CenterContent: View>: View {
    let leftTitle: String
    let rightTitle: String
    let onPrev: () -> Void
    let onNext: () -> Void
    @ViewBuilder let centerContent: () -> CenterContent

    var body: some View {
        ZStack {
            HStack {
                Button(action: onPrev) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text(leftTitle)
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text(rightTitle)
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

            // Center slot (FAB lives here)
            centerContent()
        }
        .background(.thinMaterial)
    }
}

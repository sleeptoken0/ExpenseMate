//
//  Untitled.swift
//  ExpenseMate
//
//  Created by Alex Senu

import SwiftUI

struct HomeMonthHeaderBar: View {
    let monthTitle: String
    //let onOpenCharts: () -> Void

    var body: some View {
        HStack {
            Text(monthTitle)
                .font(.title3.weight(.semibold))

            Spacer()

            //Button(action: onOpenCharts) {
            //    Image(systemName: "arrow.up.left.and.arrow.down.right")
            //        .font(.system(size: 18, weight: .bold))
            //        .frame(width: 44, height: 44)
            //        .background(.thinMaterial, in: Circle())
            //}
            .accessibilityLabel("Open charts")
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

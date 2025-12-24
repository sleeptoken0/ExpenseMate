//
//  ExpenseMateApp.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI
import SwiftData

@main
struct ExpenseMateApp: App {
    private let container = ModelContainerFactory.makeContainer()

    init() {
        let context = container.mainContext
        do {
            try SeedData.seedIfNeeded(context)
        } catch {
            print("Seed failed:", error)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}

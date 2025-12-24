//
//  PreviewData.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftData

enum PreviewData {
    static func makeContainer() -> ModelContainer {
        let container = ModelContainerFactory.makeContainer(inMemory: true)
        let context = ModelContext(container)
        do {
            try SeedData.seedIfNeeded(context)
        } catch {
            print("Preview seed failed:", error)
        }
        return container
    }
}



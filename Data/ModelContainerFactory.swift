//
//  ModelContainerFactory.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import Foundation
import SwiftData

enum ModelContainerFactory {
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Attachment.self,
            AppSettings.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}



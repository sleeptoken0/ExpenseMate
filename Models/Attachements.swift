//
//  Attachements.swift
//  ExpenseMate
//
//  Created by Alex Senu

import Foundation
import SwiftData

@Model
final class Attachment {
    @Attribute(.unique) var id: UUID
    var kindRaw: String          // AttachmentKind.rawValue
    var localIdentifier: String? // Photos identifier (optional)
    var filePath: String?        // App Documents path (optional)
    var createdAt: Date

    init(
        id: UUID = UUID(),
        kind: AttachmentKind = .photo,
        localIdentifier: String? = nil,
        filePath: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.localIdentifier = localIdentifier
        self.filePath = filePath
        self.createdAt = createdAt
    }

    var kind: AttachmentKind {
        get { AttachmentKind(rawValue: kindRaw) ?? .photo }
        set { kindRaw = newValue.rawValue }
    }
}



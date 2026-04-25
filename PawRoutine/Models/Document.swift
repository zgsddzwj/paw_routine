//
//  Document.swift
//  PawRoutine
//
//  证件夹模型 - 从 PawRoutine2 集成
//

import Foundation
import SwiftData

@Model
final class Document {
    var id: UUID
    var title: String
    var documentType: DocumentType
    var imageData: Data?
    var createdAt: Date
    
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        title: String,
        documentType: DocumentType,
        imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.documentType = documentType
        self.imageData = imageData
        self.createdAt = Date()
    }
}

enum DocumentType: String, Codable, CaseIterable, Identifiable {
    case vaccineBook = "Vaccine Book"
    case neuteringCert = "Neutering Certificate"
    case medicalReport = "Medical Report"
    case other = "Other Document"
    
    var id: String { rawValue }
    
    var displayName: String {
        NSLocalizedString(rawValue, comment: "Document type")
    }
    
    var icon: String {
        switch self {
        case .vaccineBook: return "book.closed.fill"
        case .neuteringCert: return "checkmark.seal.fill"
        case .medicalReport: return "stethoscope"
        case .other: return "doc.fill"
        }
    }
}

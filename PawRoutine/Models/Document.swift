//
//  Document.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
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
    case vaccineBook = "疫苗本"
    case neuteringCert = "绝育证明"
    case medicalReport = "体检报告"
    case other = "其他证件"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .vaccineBook: return "book.closed.fill"
        case .neuteringCert: return "checkmark.seal.fill"
        case .medicalReport: return "clipboard.medical"
        case .other: return "doc.fill"
        }
    }
}

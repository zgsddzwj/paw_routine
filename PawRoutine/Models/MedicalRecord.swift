//
//  MedicalRecord.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import SwiftData

@Model
final class MedicalRecord {
    var id: UUID
    var type: MedicalRecordType
    var title: String
    var date: Date
    var nextDueDate: Date?
    var veterinarian: String?
    var notes: String?
    var imageData: Data?
    var isReminderSet: Bool
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        type: MedicalRecordType,
        title: String? = nil,
        date: Date,
        nextDueDate: Date? = nil,
        veterinarian: String? = nil,
        notes: String? = nil,
        isReminderSet: Bool = false
    ) {
        self.id = id
        self.type = type
        self.title = title ?? type.displayName
        self.date = date
        self.nextDueDate = nextDueDate
        self.veterinarian = veterinarian
        self.notes = notes
        self.isReminderSet = isReminderSet
    }
}

enum MedicalRecordType: String, CaseIterable, Codable {
    case vaccination = "Vaccine"
    case dewormingInternal = "Internal Deworming"
    case dewormingExternal = "External Deworming"
    case checkup = "Checkup"
    case treatment = "Treatment"
    case certificate = "Certificate"
    case surgery = "Surgery"
    case other = "Other"
    
    var displayName: String {
        NSLocalizedString(rawValue, comment: "Medical record type")
    }
    
    var systemImage: String {
        switch self {
        case .vaccination: return "syringe.fill"
        case .dewormingInternal: return "cross.case.fill"
        case .dewormingExternal: return "ladybug.fill"
        case .checkup: return "stethoscope"
        case .treatment: return "cross.case"
        case .certificate: return "doc.text"
        case .surgery: return "scissors"
        case .other: return "note.text"
        }
    }
    
    /// 默认提醒间隔（天数）
    var defaultReminderInterval: Int? {
        switch self {
        case .vaccination: return nil
        case .dewormingInternal: return 90
        case .dewormingExternal: return 30
        case .checkup: return 365
        case .treatment: return nil
        case .certificate: return nil
        case .surgery: return nil
        case .other: return nil
        }
    }
}
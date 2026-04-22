//
//  MedicalRecord.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import Foundation
import SwiftData

@Model
final class MedicalRecord {
    var id: UUID
    var medicalType: MedicalType
    var title: String
    var date: Date
    var nextDueDate: Date?
    var veterinarian: String?
    var note: String?
    var isReminderSet: Bool
    
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        medicalType: MedicalType,
        title: String,
        date: Date,
        nextDueDate: Date? = nil,
        veterinarian: String? = nil,
        note: String? = nil,
        isReminderSet: Bool = false
    ) {
        self.id = id
        self.medicalType = medicalType
        self.title = title
        self.date = date
        self.nextDueDate = nextDueDate
        self.veterinarian = veterinarian
        self.note = note
        self.isReminderSet = isReminderSet
    }
}

enum MedicalType: String, Codable, CaseIterable, Identifiable {
    case vaccination = "疫苗"
    case dewormingInternal = "体内驱虫"
    case dewormingExternal = "体外驱虫"
    case checkup = "体检"
    case surgery = "手术"
    case other = "其他"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .vaccination: return "syringe.fill"
        case .dewormingInternal: return "cross.case.fill"
        case .dewormingExternal: return "ladybug.fill"
        case .checkup: return "stethoscope"
        case .surgery: return "cross.case"
        case .other: return "note.text"
        }
    }
    
    /// 默认提醒间隔（天数）
    var defaultReminderInterval: Int? {
        switch self {
        case .vaccination: return nil      // 疫苗不固定，用户手动设置
        case .dewormingInternal: return 90 // 3个月一次
        case .dewormingExternal: return 30 // 1个月一次
        case .checkup: return 365          // 每年体检
        case .surgery: return nil
        case .other: return nil
        }
    }
}

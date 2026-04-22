//
//  DailyRecord.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import Foundation
import SwiftData

@Model
final class DailyRecord {
    var id: UUID
    var recordType: RecordType
    var timestamp: Date
    var note: String?
    
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        recordType: RecordType,
        timestamp: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.recordType = recordType
        self.timestamp = timestamp
        self.note = note
    }
}

enum RecordType: String, Codable, CaseIterable, Identifiable {
    case feeding = "喂食"
    case water = "换水"
    case walking = "遛狗"
    case medication = "喂药"
    case bathroom = "排便"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .feeding: return "fork.knife"
        case .water: return "drop.fill"
        case .walking: return "figure.walk"
        case .medication: return "pills.fill"
        case .bathroom: return "drop.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .feeding: return "🍖"
        case .water: return "💧"
        case .walking: return "🦮"
        case .medication: return "💊"
        case .bathroom: return "💩"
        }
    }
    
    /// 默认每日目标次数
    var defaultDailyGoal: Int {
        switch self {
        case .feeding: return 3
        case .water: return 2
        case .walking: return 2
        case .medication: return 1
        case .bathroom: return 3
        }
    }
    
    /// 颜色标识
    var color: String {
        switch self {
        case .feeding: return "orange"
        case .water: return "blue"
        case .walking: return "green"
        case .medication: return "red"
        case .bathroom: return "brown"
        }
    }
}

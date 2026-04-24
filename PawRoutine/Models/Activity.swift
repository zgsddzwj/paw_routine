//
//  Activity.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import SwiftData

@Model
final class Activity {
    var type: ActivityType
    var timestamp: Date
    var notes: String?
    var duration: Int? // 时长（分钟），主要用于遛狗
    var pet: Pet?
    
    init(type: ActivityType, timestamp: Date = Date(), notes: String? = nil, duration: Int? = nil) {
        self.type = type
        self.timestamp = timestamp
        self.notes = notes
        self.duration = duration
    }
}

enum ActivityType: String, CaseIterable, Codable {
    case feeding = "喂食"
    case waterChange = "换水"
    case walking = "遛狗"
    case medication = "喂药"
    case defecation = "排便"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .feeding: return "🍖"
        case .waterChange: return "💧"
        case .walking: return "🦮"
        case .medication: return "💊"
        case .defecation: return "💩"
        case .other: return "📝"
        }
    }
    
    var systemImage: String {
        switch self {
        case .feeding: return "fork.knife"
        case .waterChange: return "drop.fill"
        case .walking: return "figure.walk"
        case .medication: return "pills.fill"
        case .defecation: return "circle.fill"
        case .other: return "note.text"
        }
    }
    
    /// 默认每日目标次数
    var defaultDailyGoal: Int {
        switch self {
        case .feeding: return 3
        case .waterChange: return 2
        case .walking: return 2
        case .medication: return 1
        case .defecation: return 3
        case .other: return 1
        }
    }
    
    /// 颜色标识
    var themeColor: String {
        switch self {
        case .feeding: return "orange"
        case .waterChange: return "blue"
        case .walking: return "green"
        case .medication: return "red"
        case .defecation: return "brown"
        case .other: return "gray"
        }
    }
}
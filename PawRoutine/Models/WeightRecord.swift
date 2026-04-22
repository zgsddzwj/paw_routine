//
//  WeightRecord.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import Foundation
import SwiftData

@Model
final class WeightRecord {
    var id: UUID
    var weight: Double          // 单位：kg
    var timestamp: Date
    var note: String?
    
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        weight: Double,
        timestamp: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.weight = weight
        self.timestamp = timestamp
        self.note = note
    }
}

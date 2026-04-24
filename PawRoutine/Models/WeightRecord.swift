//
//  WeightRecord.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import SwiftData

@Model
final class WeightRecord {
    var weight: Double // in kg
    var date: Date
    var notes: String?
    var pet: Pet?
    
    init(weight: Double, date: Date = Date(), notes: String? = nil) {
        self.weight = weight
        self.date = date
        self.notes = notes
    }
}
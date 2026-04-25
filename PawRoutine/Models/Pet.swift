//
//  Pet.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import SwiftData

@Model
final class Pet {
    var id: UUID
    var name: String
    var breed: String
    var gender: Gender
    var birthDate: Date
    var isNeutered: Bool
    var profileImageData: Data?
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var activities: [Activity] = []
    @Relationship(deleteRule: .cascade) var medicalRecords: [MedicalRecord] = []
    @Relationship(deleteRule: .cascade) var weightRecords: [WeightRecord] = []
    @Relationship(deleteRule: .cascade) var documents: [Document] = []
    
    init(id: UUID = UUID(), name: String, breed: String, gender: Gender, birthDate: Date, isNeutered: Bool = false) {
        self.id = id
        self.name = name
        self.breed = breed
        self.gender = gender
        self.birthDate = birthDate
        self.isNeutered = isNeutered
        self.createdAt = Date()
    }
    
    // Computed properties
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
    }
    
    var ageInHumanYears: Double {
        let ageInYears = Double(ageInDays) / 365.25
        // Simple dog age calculation (first year = 15 human years, second year = 9, then 5 per year)
        if ageInYears <= 1 {
            return ageInYears * 15
        } else if ageInYears <= 2 {
            return 15 + (ageInYears - 1) * 9
        } else {
            return 15 + 9 + (ageInYears - 2) * 5
        }
    }
    
    var ageDescription: String {
        let years = ageInDays / 365
        let months = (ageInDays % 365) / 30
        let days = ageInDays % 30
        
        if years > 0 {
            return String(format: NSLocalizedString("%d岁 %d个月 %d天", comment: ""), years, months, days)
        } else if months > 0 {
            return String(format: NSLocalizedString("%d个月 %d天", comment: ""), months, days)
        } else {
            return String(format: NSLocalizedString("%d天", comment: ""), days)
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    
    var displayName: String {
        NSLocalizedString(rawValue, comment: "Pet gender")
    }
}
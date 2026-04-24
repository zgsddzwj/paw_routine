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
    
    init(name: String, breed: String, gender: Gender, birthDate: Date, isNeutered: Bool = false) {
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
            return "\(years)岁 \(months)个月 \(days)天"
        } else if months > 0 {
            return "\(months)个月 \(days)天"
        } else {
            return "\(days)天"
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "公"
    case female = "母"
}
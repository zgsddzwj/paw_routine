//
//  Pet.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

@Model
final class Pet {
    var id: UUID
    var name: String
    var breed: String
    var petType: PetType
    var gender: Gender
    var isNeutered: Bool
    var birthDate: Date?
    var avatarData: Data?
    var createdAt: Date
    var sortOrder: Int
    
    @Relationship(deleteRule: .cascade, inverse: \DailyRecord.pet)
    var dailyRecords: [DailyRecord]
    
    @Relationship(deleteRule: .cascade, inverse: \WeightRecord.pet)
    var weightRecords: [WeightRecord]
    
    @Relationship(deleteRule: .cascade, inverse: \MedicalRecord.pet)
    var medicalRecords: [MedicalRecord]
    
    @Relationship(deleteRule: .cascade, inverse: \Document.pet)
    var documents: [Document]
    
    init(
        id: UUID = UUID(),
        name: String,
        breed: String = "",
        petType: PetType = .dog,
        gender: Gender = .male,
        isNeutered: Bool = false,
        birthDate: Date? = nil,
        avatarData: Data? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.petType = petType
        self.gender = gender
        self.isNeutered = isNeutered
        self.birthDate = birthDate
        self.avatarData = avatarData
        self.createdAt = Date()
        self.sortOrder = sortOrder
        self.dailyRecords = []
        self.weightRecords = []
        self.medicalRecords = []
        self.documents = []
    }
}

// MARK: - Helper Computed Properties

extension Pet {
    /// 计算精确年龄（年、月、日）
    var ageComponents: (years: Int, months: Int, days: Int)? {
        guard let birthDate else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate, to: Date())
        
        guard let years = components.year,
              let months = components.month,
              let days = components.day else {
            return nil
        }
        
        return (years, months, days)
    }
    
    /// 格式化的年龄字符串
    var ageDisplayString: String? {
        guard let age = ageComponents else { return nil }
        
        if age.years > 0 {
            return "\(age.years)岁\(age.months)个月"
        } else if age.months > 0 {
            return "\(age.months)个月\(age.days)天"
        } else {
            return "\(age.days)天"
        }
    }
    
    /// 换算为人类年龄（粗略估算）
    var humanAge: Double? {
        guard let birthDate else { return nil }
        
        let calendar = Calendar.current
        let ageInYears = calendar.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        
        switch petType {
        case .dog:
            // 狗的人类年龄换算公式（简化版）
            if ageInYears <= 1 {
                return Double(ageInYears) * 15.0
            } else if ageInYears <= 2 {
                return 15.0 + Double(ageInYears - 1) * 9.0
            } else {
                return 24.0 + Double(ageInYears - 2) * 5.0
            }
        case .cat:
            // 猫的人类年龄换算公式（简化版）
            if ageInYears <= 1 {
                return Double(ageInYears) * 15.0
            } else if ageInYears <= 2 {
                return 15.0 + Double(ageInYears - 1) * 9.0
            } else {
                return 24.0 + Double(ageInYears - 2) * 4.0
            }
        case .other:
            return Double(ageInYears) * 7.0 // 其他宠物通用算法
        }
    }
    
    /// 获取头像 UIImage
    var avatarImage: Image? {
        guard let avatarData else { return nil }
        guard let uiImage = UIImage(data: avatarData) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    /// 今日记录
    var todayRecords: [DailyRecord] {
        let calendar = Calendar.current
        return dailyRecords.filter { calendar.isDateInToday($0.timestamp) }
    }
}

// MARK: - Enums

enum PetType: String, Codable, CaseIterable, Identifiable {
    case dog = "狗"
    case cat = "猫"
    case other = "其他"
    
    var id: RawValue { rawValue }
    
    var icon: String {
        switch self {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .other: return "pawprint.fill"
        }
    }
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "公"
    case female = "母"
    case unknown = "未知"
    
    var id: RawValue { rawValue }
    
    var icon: String {
        switch self {
        case .male: return "mars"
        case .female: return "venus"
        case .unknown: return "questionmark"
        }
    }
}

//
//  SampleData.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import SwiftData

struct SampleData {
    
    static func createSamplePet(in modelContext: ModelContext) -> Pet {
        let pet = Pet(
            name: "小白",
            breed: "金毛寻回犬",
            gender: .male,
            birthDate: Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date(),
            isNeutered: true
        )
        
        modelContext.insert(pet)
        
        // Add some sample activities
        let activities = createSampleActivities(for: pet)
        activities.forEach { modelContext.insert($0) }
        
        // Add some sample medical records
        let medicalRecords = createSampleMedicalRecords(for: pet)
        medicalRecords.forEach { modelContext.insert($0) }
        
        // Add some sample weight records
        let weightRecords = createSampleWeightRecords(for: pet)
        weightRecords.forEach { modelContext.insert($0) }
        
        return pet
    }
    
    private static func createSampleActivities(for pet: Pet) -> [Activity] {
        var activities: [Activity] = []
        let calendar = Calendar.current
        
        // Create activities for the past week
        for dayOffset in 0...6 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            
            // Morning feeding
            if let morningTime = calendar.date(bySettingHour: 7, minute: Int.random(in: 0...30), second: 0, of: date) {
                let activity = Activity(type: .feeding, timestamp: morningTime)
                activity.pet = pet
                activities.append(activity)
            }
            
            // Evening feeding  
            if let eveningTime = calendar.date(bySettingHour: 18, minute: Int.random(in: 0...30), second: 0, of: date) {
                let activity = Activity(type: .feeding, timestamp: eveningTime)
                activity.pet = pet
                activities.append(activity)
            }
            
            // Walking (1-2 times per day)
            let walkCount = Int.random(in: 1...2)
            for _ in 0..<walkCount {
                let hour = Int.random(in: 8...20)
                let minute = Int.random(in: 0...59)
                if let walkTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) {
                    let activity = Activity(type: .walking, timestamp: walkTime)
                    activity.pet = pet
                    activities.append(activity)
                }
            }
            
            // Water change (every 2-3 days)
            if dayOffset % 2 == 0 {
                let hour = Int.random(in: 9...11)
                if let waterTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) {
                    let activity = Activity(type: .waterChange, timestamp: waterTime)
                    activity.pet = pet
                    activities.append(activity)
                }
            }
            
            // Occasional defecation records
            if Bool.random() {
                let hour = Int.random(in: 8...20)
                let minute = Int.random(in: 0...59)
                if let defecationTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) {
                    let activity = Activity(type: .defecation, timestamp: defecationTime, notes: Bool.random() ? "Normal" : nil)
                    activity.pet = pet
                    activities.append(activity)
                }
            }
        }
        
        return activities
    }
    
    private static func createSampleMedicalRecords(for pet: Pet) -> [MedicalRecord] {
        var records: [MedicalRecord] = []
        let calendar = Calendar.current
        
        // Vaccination record
        if let vaccinationDate = calendar.date(byAdding: .month, value: -6, to: Date()) {
            let nextVaccination = calendar.date(byAdding: .year, value: 1, to: vaccinationDate)
            let vaccination = MedicalRecord(
                type: .vaccination,
                date: vaccinationDate,
                nextDueDate: nextVaccination,
                notes: "狂犬疫苗 + 六联疫苗"
            )
            vaccination.pet = pet
            records.append(vaccination)
        }
        
        // Deworming record
        if let dewormingDate = calendar.date(byAdding: .month, value: -2, to: Date()) {
            let nextDeworming = calendar.date(byAdding: .month, value: 3, to: dewormingDate)
            let deworming = MedicalRecord(
                type: .dewormingInternal,
                date: dewormingDate,
                nextDueDate: nextDeworming,
                notes: "体内外驱虫"
            )
            deworming.pet = pet
            records.append(deworming)
        }
        
        // Checkup record
        if let checkupDate = calendar.date(byAdding: .month, value: -3, to: Date()) {
            let checkup = MedicalRecord(
                type: .checkup,
                date: checkupDate,
                notes: "年度体检，各项指标正常"
            )
            checkup.pet = pet
            records.append(checkup)
        }
        
        return records
    }
    
    private static func createSampleWeightRecords(for pet: Pet) -> [WeightRecord] {
        var records: [WeightRecord] = []
        let calendar = Calendar.current
        
        // Create weight records over the past 6 months
        var baseWeight = 25.0 // kg
        
        for monthOffset in 0...5 {
            guard let date = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) else { continue }
            
            // Slight weight variation
            let weightVariation = Double.random(in: -0.5...0.3)
            baseWeight += weightVariation
            
            let record = WeightRecord(
                weight: max(baseWeight, 20.0), // Minimum 20kg
                date: date,
                notes: monthOffset == 0 ? "最新称重" : nil
            )
            record.pet = pet
            records.append(record)
        }
        
        return records.reversed() // Chronological order
    }
    
    // MARK: - Helper Methods for Testing
    
    static func generateRandomActivity(for pet: Pet) -> Activity {
        let types = ActivityType.allCases
        let randomType = types.randomElement() ?? .feeding
        
        let randomHour = Int.random(in: 6...22)
        let randomMinute = Int.random(in: 0...59)
        let calendar = Calendar.current
        let timestamp = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: Date()) ?? Date()
        
        let notes: String? = Bool.random() ? ["Normal", "有点拉稀", "很开心", "吃得很香"].randomElement() : nil
        
        let activity = Activity(type: randomType, timestamp: timestamp, notes: notes)
        activity.pet = pet
        return activity
    }
    
    static func clearAllData(in modelContext: ModelContext) {
        // Delete all pets (cascade will delete related data)
        let fetchDescriptor = FetchDescriptor<Pet>()
        do {
            let pets = try modelContext.fetch(fetchDescriptor)
            pets.forEach { modelContext.delete($0) }
        } catch {
            #if DEBUG
            print("Failed to clear data: \(error)")
            #endif
        }
    }
}
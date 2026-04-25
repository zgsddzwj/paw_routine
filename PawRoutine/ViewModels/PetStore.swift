//
//  PetStore.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

class PetStore: ObservableObject {
    @Published var selectedPet: Pet?
    @Published var showingQuickAdd = false
    @Published var showingAddPet = false
    
    @AppStorage("selectedPetID") private var selectedPetIDString: String = ""
    
    func selectPet(_ pet: Pet) {
        selectedPet = pet
        selectedPetIDString = pet.id.uuidString
    }
    
    func restoreSelectedPet(from pets: [Pet]) {
        if selectedPet == nil, !selectedPetIDString.isEmpty {
            selectedPet = pets.first { $0.id.uuidString == selectedPetIDString }
        }
        if selectedPet == nil, let first = pets.first {
            selectedPet = first
        }
    }
    
    func getTodayActivities(for pet: Pet) -> [Activity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return pet.activities.filter { activity in
            activity.timestamp >= today && activity.timestamp < tomorrow
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    func getActivityCount(for pet: Pet, type: ActivityType, on date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return pet.activities.filter { activity in
            activity.type == type &&
            activity.timestamp >= startOfDay &&
            activity.timestamp < endOfDay
        }.count
    }
}
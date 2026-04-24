//
//  Settings.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    var morningFeedingTime: Date
    var eveningFeedingTime: Date
    var morningWalkTime: Date
    var eveningWalkTime: Date
    var waterChangeTime: Date
    var walkingTimes: [Date]
    var reminderEnabled: Bool
    var feedingReminderEnabled: Bool
    var waterReminderEnabled: Bool
    var walkReminderEnabled: Bool
    var medicationReminderEnabled: Bool
    var isPro: Bool
    
    init(
        id: UUID = UUID(),
        morningFeedingTime: Date? = nil,
        eveningFeedingTime: Date? = nil,
        morningWalkTime: Date? = nil,
        eveningWalkTime: Date? = nil,
        waterChangeTime: Date? = nil
    ) {
        let calendar = Calendar.current
        let defaultMorningWalk = morningWalkTime ?? calendar.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date()
        let defaultEveningWalk = eveningWalkTime ?? calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        
        self.id = id
        self.morningFeedingTime = morningFeedingTime ?? calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        self.eveningFeedingTime = eveningFeedingTime ?? calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
        self.morningWalkTime = defaultMorningWalk
        self.eveningWalkTime = defaultEveningWalk
        self.waterChangeTime = waterChangeTime ?? calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        self.walkingTimes = [defaultMorningWalk, defaultEveningWalk]
        self.reminderEnabled = true
        self.feedingReminderEnabled = true
        self.waterReminderEnabled = true
        self.walkReminderEnabled = true
        self.medicationReminderEnabled = true
        self.isPro = false
    }
}
//
//  ReminderSettings.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    var isPro: Bool
    
    // 默认提醒时间
    var morningFeedingTime: Date       // 早上喂食时间
    var eveningFeedingTime: Date       // 晚上喂食时间
    var morningWalkTime: Date          // 早上遛狗时间
    var eveningWalkTime: Date          // 晚上遛狗时间
    
    // 提醒开关
    var feedingReminderEnabled: Bool
    var waterReminderEnabled: Bool
    var walkReminderEnabled: Bool
    var medicationReminderEnabled: Bool
    
    init(
        id: UUID = UUID(),
        isPro: Bool = false,
        morningFeedingTime: Date = {
            let components = DateComponents(hour: 8, minute: 0)
            return Calendar.current.date(from: components) ?? Date()
        }(),
        eveningFeedingTime: Date = {
            let components = DateComponents(hour: 18, minute: 0)
            return Calendar.current.date(from: components) ?? Date()
        }(),
        morningWalkTime: Date = {
            let components = DateComponents(hour: 7, minute: 30)
            return Calendar.current.date(from: components) ?? Date()
        }(),
        eveningWalkTime: Date = {
            let components = DateComponents(hour: 20, minute: 0)
            return Calendar.current.date(from: components) ?? Date()
        }(),
        feedingReminderEnabled: Bool = true,
        waterReminderEnabled: Bool = true,
        walkReminderEnabled: Bool = true,
        medicationReminderEnabled: Bool = true
    ) {
        self.id = id
        self.isPro = isPro
        self.morningFeedingTime = morningFeedingTime
        self.eveningFeedingTime = eveningFeedingTime
        self.morningWalkTime = morningWalkTime
        self.eveningWalkTime = eveningWalkTime
        self.feedingReminderEnabled = feedingReminderEnabled
        self.waterReminderEnabled = waterReminderEnabled
        self.walkReminderEnabled = walkReminderEnabled
        self.medicationReminderEnabled = medicationReminderEnabled
    }
}

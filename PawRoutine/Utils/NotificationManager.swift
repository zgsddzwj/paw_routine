//
//  NotificationManager.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import Foundation
import UserNotifications
import SwiftData

/// Manages all local notification scheduling for the app.
/// Uses @Observable for iOS 17+ compatibility with SwiftData.
@Observable
final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Daily Reminders (绑定了 AppSettings 开关)
    
    /// 为单个宠物根据当前 AppSettings 调度所有开启的日常提醒
    func scheduleDailyReminders(for pet: Pet, settings: AppSettings) {
        removeDailyReminders(for: pet)
        
        if settings.feedingReminderEnabled {
            scheduleActivityReminder(for: pet, activityType: .feeding, at: settings.morningFeedingTime, suffix: "morning")
            scheduleActivityReminder(for: pet, activityType: .feeding, at: settings.eveningFeedingTime, suffix: "evening")
        }
        
        if settings.walkReminderEnabled {
            scheduleActivityReminder(for: pet, activityType: .walking, at: settings.morningWalkTime, suffix: "morning")
            scheduleActivityReminder(for: pet, activityType: .walking, at: settings.eveningWalkTime, suffix: "evening")
        }
        
        if settings.waterReminderEnabled {
            scheduleActivityReminder(for: pet, activityType: .waterChange, at: settings.waterChangeTime, suffix: "daily")
        }
    }
    
    /// 当 AppSettings 变更时，为所有宠物重新调度日常提醒
    func rescheduleDailyReminders(for pets: [Pet], settings: AppSettings) {
        for pet in pets {
            scheduleDailyReminders(for: pet, settings: settings)
        }
    }
    
    /// 取消单个宠物的所有日常提醒
    func removeDailyReminders(for pet: Pet) {
        let petIDString = petIDString(from: pet)
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.compactMap { request in
                request.identifier.hasPrefix("daily_\(petIDString)_") ? request.identifier : nil
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    // MARK: - Activity Reminders
    
    private func scheduleActivityReminder(for pet: Pet, activityType: ActivityType, at time: Date, suffix: String) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("🐾 Pet Reminder", comment: "")
        content.body = String(format: NSLocalizedString("该为 %@ %@了", comment: ""), pet.name, activityType.displayName)
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let petIDString = petIDString(from: pet)
        let identifier = "daily_\(petIDString)_\(activityType.rawValue)_\(suffix)_\(components.hour ?? 0)_\(components.minute ?? 0)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("Failed to schedule notification: \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    // MARK: - Medical Reminders
    
    func scheduleMedicalReminder(for record: MedicalRecord, pet: Pet) {
        guard let dueDate = record.nextDueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("🏥 Medical Reminder", comment: "")
        content.body = String(format: NSLocalizedString("%@ 需要进行 %@", comment: ""), pet.name, record.type.displayName)
        content.sound = .default
        
        let calendar = Calendar.current
        let triggerDate = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: dueDate)) ?? dueDate
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let petIDString = petIDString(from: pet)
        let recordIDString = recordIDString(from: record)
        let identifier = "medical_\(recordIDString)_\(petIDString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("Failed to schedule medical reminder: \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    // MARK: - Notification Management
    
    func removeAllNotifications(for pet: Pet) {
        let petIDString = petIDString(from: pet)
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.compactMap { request in
                request.identifier.contains(petIDString) ? request.identifier : nil
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Helper Methods
    
    /// Use Pet's UUID as stable identifier
    private func petIDString(from pet: Pet) -> String {
        return pet.id.uuidString
    }
    
    /// Use MedicalRecord's UUID as stable identifier
    private func recordIDString(from record: MedicalRecord) -> String {
        return record.id.uuidString
    }
}

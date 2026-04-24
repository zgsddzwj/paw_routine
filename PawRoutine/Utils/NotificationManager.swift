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
    
    // MARK: - Activity Reminders
    
    func scheduleActivityReminder(for pet: Pet, activityType: ActivityType, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "宠物提醒"
        content.body = "该为 \(pet.name) \(activityType.rawValue)了"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Use hash of PersistentIdentifier for stable string ID
        let petIDString = petIDString(from: pet)
        let identifier = "pet_\(petIDString)_\(activityType.rawValue)_\(components.hour ?? 0)_\(components.minute ?? 0)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification for \(pet.name) - \(activityType.rawValue)")
            }
        }
    }
    
    // MARK: - Medical Reminders
    
    func scheduleMedicalReminder(for record: MedicalRecord, pet: Pet) {
        guard let dueDate = record.nextDueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "医疗提醒"
        content.body = "\(pet.name) 需要进行 \(record.type.rawValue)"
        content.sound = .default
        content.badge = 1
        
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
                print("Failed to schedule medical reminder: \(error.localizedDescription)")
            } else {
                print("Scheduled medical reminder for \(pet.name) - \(record.type.rawValue)")
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
    
    /// Convert Pet's PersistentIdentifier to a usable string
    private func petIDString(from pet: Pet) -> String {
        let id = pet.persistentModelID
        return id.hashValue.description
    }
    
    /// Convert MedicalRecord's PersistentIdentifier to a usable string
    private func recordIDString(from record: MedicalRecord) -> String {
        let id = record.persistentModelID
        return id.hashValue.description
    }
}

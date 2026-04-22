//
//  NotificationManager.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import Foundation
import UserNotifications

/// 统一管理本地推送通知
final class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - 请求权限
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    // MARK: - 医疗提醒
    
    /// 安排医疗记录的下次提醒（如驱虫、疫苗等）
    func scheduleMedicalReminder(for pet: Pet, title: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🏥 医疗提醒"
        content.body = "\(pet.name) 的「\(title)」时间到了，别忘了安排！"
        content.sound = .default
        content.badge = 1
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "medical_\(pet.id.uuidString)_\(title)_\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error {
                print("Failed to schedule medical reminder: \(error)")
            } else {
                print("Scheduled medical reminder for \(pet.name): \(title)")
            }
        }
    }
    
    // MARK: - 喂食提醒
    
    /// 安排每日喂食提醒
    func scheduleFeedingReminders(morningTime: Date, eveningTime: Date, for pet: Pet? = nil) {
        // 早上喂食
        scheduleDailyReminder(
            id: "feeding_morning_\(pet?.id.uuidString ?? "default")",
            title: "🍖 该喂饭啦！",
            body: pet != nil ? "\(pet!.name) 的早餐时间到了~" : "该给毛孩子准备早饭了",
            time: morningTime,
            repeats: true
        )
        
        // 晚上喂食
        scheduleDailyReminder(
            id: "feeding_evening_\(pet?.id.uuidString ?? "default")",
            title: "🍖 晚餐时间到！",
            body: pet != nil ? "\(pet!.name) 的晚餐时间到了~" : "该给毛孩子准备晚饭了",
            time: eveningTime,
            repeats: true
        )
    }
    
    // MARK: - 遛狗提醒
    
    /// 安排每日遛狗提醒
    func scheduleWalkReminders(morningTime: Date, eveningTime: Date, for pet: Pet? = nil) {
        scheduleDailyReminder(
            id: "walk_morning_\(pet?.id.uuidString ?? "default")",
            title: "🦮 出门遛遛吧！",
            body: pet != nil ? "带 \(pet!.name) 出去走走，呼吸新鲜空气~" : "天气不错，出去遛遛狗吧！",
            time: morningTime,
            repeats: true
        )
        
        scheduleDailyReminder(
            id: "walk_evening_\(pet?.id.uuidString ?? "default")",
            title: "🌙 晚间散步时间",
            body: pet != nil ? "带 \(pet!.name) 散散步，放松一下吧~" : "晚间散步时间到了！",
            time: eveningTime,
            repeats: true
        )
    }
    
    // MARK: - 换水提醒
    
    func scheduleWaterReminder(time: Date, for pet: Pet? = nil) {
        scheduleDailyReminder(
            id: "water_\(pet?.id.uuidString ?? "default")",
            title: "💧 记得换水哦",
            body: pet != nil ? "检查一下 \(pet!.name) 的水碗是否干净~" : "别忘了给毛孩子换新鲜的水",
            time: time,
            repeats: true
        )
    }
    
    // MARK: - Helper
    
    private func scheduleDailyReminder(id: String, title: String, body: String, time: Date, repeats: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error {
                print("Failed to schedule reminder [\(id)]: \(error)")
            }
        }
    }
    
    // MARK: - 取消所有提醒
    
    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// 取消特定宠物的所有提醒
    func cancelReminders(for petId: UUID) {
        center.getPendingNotificationRequests { requests in
            let toCancel = requests.filter { $0.identifier.contains(petId.uuidString) }
            self.center.removePendingNotificationRequests(withIdentifiers: toCancel.map(\.identifier))
        }
    }
}

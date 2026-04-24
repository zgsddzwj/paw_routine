//
//  TodayTimelineView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI

struct TodayTimelineView: View {
    let pet: Pet
    @EnvironmentObject private var petStore: PetStore
    
    var todayActivities: [Activity] {
        petStore.getTodayActivities(for: pet)
    }
    
    // Generate upcoming reminders based on settings (simplified)
    private var upcomingReminders: [(String, String, String)] {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        var reminders: [(String, String, String)] = []
        
        // Default reminder times matching design
        if hour < 8 {
            reminders.append(("08:30", "喂食（早餐）", "🍖"))
            reminders.append(("09:00", "换水", "💧"))
        }
        if hour < 12 {
            reminders.append(("12:15", "遛狗", "🦮"))
        }
        if hour < 16 {
            reminders.append(("16:00", "喂食（晚餐）", "🍖"))
        }
        if hour < 20 {
            reminders.append(("20:00", "遛狗", "🦮"))
        }
        
        // Filter out past times more precisely
        return reminders.filter { timeStr, _, _ in
            guard let reminderTime = parseTime(timeStr) else { return true }
            return reminderTime > now
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日时间轴")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Completed activities
            if !todayActivities.isEmpty {
                LazyVStack(spacing: 10) {
                    ForEach(todayActivities) { activity in
                        TimelineItemView(activity: activity)
                    }
                }
            } else {
                EmptyTimelineView()
            }
            
            // Upcoming Reminders Section (NEW - matching design)
            if !upcomingReminders.isEmpty {
                Divider()
                
                HStack {
                    Text("即将到来")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.top, 4)
                
                LazyVStack(spacing: 10) {
                    ForEach(upcomingReminders.indices, id: \.self) { index in
                        let reminder = upcomingReminders[index]
                        UpcomingReminderRow(
                            time: reminder.0,
                            title: reminder.1,
                            icon: reminder.2
                        )
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    /// Parse a time string like "08:30" into today's date
    private func parseTime(_ timeStr: String) -> Date? {
        let components = timeStr.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return nil }
        let calendar = Calendar.current
        return calendar.date(bySettingHour: components[0], minute: components[1], second: 0, of: Date())
    }
}

struct TimelineItemView: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Time
            VStack {
                Text(activity.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            .frame(width: 50)
            
            // Activity indicator - completed checkmark style
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 22, height: 22)
                
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(activity.type.icon)
                        .font(.body)
                    
                    Text(activity.type.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Checkmark for completed items
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - NEW: Upcoming Reminder Row
struct UpcomingReminderRow: View {
    let time: String
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Time
            Text(time)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 50)
            
            // Pending indicator circle
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                    .foregroundColor(.blue.opacity(0.4))
                    .frame(width: 22, height: 22)
            }
            
            // Content
            HStack(spacing: 6) {
                Text(icon)
                    .font(.body)
                
                Text(title)
                    .font(.body)
                
                Spacer()
                
                // Optional tag like "提醒"
                Text("提醒")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.quaternary.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyTimelineView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .font(.title)
                .foregroundColor(.gray)
            
            Text("今天还没有活动记录")
                .font(.body)
                .fontWeight(.medium)
            
            Text("点击右下角的 + 按钮开始记录")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
}

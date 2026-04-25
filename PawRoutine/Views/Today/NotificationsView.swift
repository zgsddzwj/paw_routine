//
//  NotificationsView.swift
//  PawRoutine
//
//  提醒中心 - 首页铃铛入口
//

import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var pets: [Pet]
    @Query private var settings: [AppSettings]
    
    private var currentSettings: AppSettings {
        settings.first ?? AppSettings()
    }
    
    // MARK: - 今日日常提醒
    
    private var todayReminders: [(time: Date, title: LocalizedStringKey, type: ActivityType, color: Color)] {
        var reminders: [(time: Date, title: LocalizedStringKey, type: ActivityType, color: Color)] = []
        
        if currentSettings.feedingReminderEnabled {
            reminders.append((currentSettings.morningFeedingTime, "Feeding (Breakfast)", .feeding, PawRoutineTheme.Colors.feeding))
            reminders.append((currentSettings.eveningFeedingTime, "Feeding (Dinner)", .feeding, PawRoutineTheme.Colors.feeding))
        }
        
        if currentSettings.walkReminderEnabled {
            reminders.append((currentSettings.morningWalkTime, "Walking", .walking, PawRoutineTheme.Colors.walking))
            reminders.append((currentSettings.eveningWalkTime, "Walking", .walking, PawRoutineTheme.Colors.walking))
        }
        
        if currentSettings.waterReminderEnabled {
            reminders.append((currentSettings.waterChangeTime, "Water Change", .waterChange, PawRoutineTheme.Colors.water))
        }
        
        return reminders.sorted { $0.time < $1.time }
    }
    
    // MARK: - 健康提醒（ upcoming medical records ）
    
    private var healthReminders: [(pet: Pet, record: MedicalRecord, daysLeft: Int)] {
        let now = Date()
        let calendar = Calendar.current
        
        var results: [(pet: Pet, record: MedicalRecord, daysLeft: Int)] = []
        
        for pet in pets {
            for record in pet.medicalRecords {
                guard let nextDue = record.nextDueDate else { continue }
                let daysLeft = calendar.dateComponents([.day], from: now, to: nextDue).day ?? 0
                results.append((pet, record, daysLeft))
            }
        }
        
        return results.sorted { $0.daysLeft < $1.daysLeft }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawRoutineTheme.Spacing.xl) {
                        // 今日提醒
                        todayRemindersSection
                        
                        // 健康提醒
                        healthRemindersSection
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.sm)
                    .padding(.bottom, PawRoutineTheme.Spacing.xxxl)
                }
            }
            .navigationTitle("Reminder Center")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var todayRemindersSection: some View {
        VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
            Text("Today's Reminders")
                .font(PawRoutineTheme.PRFont.title3(.bold))
                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
            
            if todayReminders.isEmpty {
                PREmptyState(
                    icon: "bell.slash",
                    title: "No reminders today",
                    subtitle: "Go to Settings to enable daily reminders"
                )
                .padding(.vertical, 24)
            } else {
                VStack(spacing: PawRoutineTheme.Spacing.md) {
                    ForEach(Array(todayReminders.enumerated()), id: \.offset) { _, reminder in
                        PRCard(padding: .init(top: 14, leading: 16, bottom: 14, trailing: 16)) {
                            HStack(spacing: PawRoutineTheme.Spacing.md) {
                                ActivityTypeIcon(type: reminder.type, size: 22)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(reminder.title)
                                        .font(PawRoutineTheme.PRFont.bodyText(.medium))
                                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                    
                                    Text(reminder.time, format: .dateTime.hour().minute())
                                        .font(PawRoutineTheme.PRFont.caption())
                                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(reminder.color.opacity(0.15))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var healthRemindersSection: some View {
        VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
            Text("Health Reminders")
                .font(PawRoutineTheme.PRFont.title3(.bold))
                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
            
            if healthReminders.isEmpty {
                PREmptyState(
                    icon: "heart.text.square",
                    title: "No health reminders",
                    subtitle: "Set a next due date in medical records to generate reminders"
                )
                .padding(.vertical, 24)
            } else {
                VStack(spacing: PawRoutineTheme.Spacing.md) {
                    ForEach(Array(healthReminders.enumerated()), id: \.offset) { _, item in
                        PRCard(padding: .init(top: 14, leading: 16, bottom: 14, trailing: 16)) {
                            HStack(spacing: PawRoutineTheme.Spacing.md) {
                                Image(systemName: item.record.type.systemImage)
                                    .font(.system(size: 18))
                                    .foregroundStyle(item.daysLeft < 0 ? .red : PawRoutineTheme.Colors.primary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        (item.daysLeft < 0 ? Color.red : PawRoutineTheme.Colors.primary).opacity(0.1),
                                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(item.pet.name) · \(item.record.title)")
                                        .font(PawRoutineTheme.PRFont.bodyText(.medium))
                                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                    
                                    if item.daysLeft < 0 {
                                        Text(String(format: NSLocalizedString("已逾期 %d 天", comment: ""), -item.daysLeft))
                                            .font(PawRoutineTheme.PRFont.caption(.semibold))
                                            .foregroundStyle(.red)
                                    } else if item.daysLeft == 0 {
                                        Text("Due Today")
                                            .font(PawRoutineTheme.PRFont.caption(.semibold))
                                            .foregroundStyle(PawRoutineTheme.Colors.walking)
                                    } else {
                                        Text(String(format: NSLocalizedString("%d 天后到期", comment: ""), item.daysLeft))
                                            .font(PawRoutineTheme.PRFont.caption())
                                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

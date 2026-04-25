//
//  TodayTimelineView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData

struct TodayTimelineView: View {
    let pet: Pet
    @EnvironmentObject private var petStore: PetStore
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    
    @State private var selectedActivity: Activity?
    
    private var currentSettings: AppSettings {
        settings.first ?? AppSettings()
    }
    
    var todayActivities: [Activity] {
        petStore.getTodayActivities(for: pet)
    }
    
    private var upcomingReminders: [(String, LocalizedStringKey, ActivityType)] {
        let now = Date()
        
        var reminders: [(time: Date, title: LocalizedStringKey, type: ActivityType)] = []
        
        if currentSettings.feedingReminderEnabled {
            reminders.append((currentSettings.morningFeedingTime, "Feeding (Breakfast)", .feeding))
            reminders.append((currentSettings.eveningFeedingTime, "Feeding (Dinner)", .feeding))
        }
        
        if currentSettings.walkReminderEnabled {
            reminders.append((currentSettings.morningWalkTime, "Walking", .walking))
            reminders.append((currentSettings.eveningWalkTime, "Walking", .walking))
        }
        
        if currentSettings.waterReminderEnabled {
            reminders.append((currentSettings.waterChangeTime, "Water Change", .waterChange))
        }
        
        let filtered = reminders.filter { $0.time > now }
            .sorted { $0.time < $1.time }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return filtered.map { (formatter.string(from: $0.time), $0.title, $0.type) }
    }
    
    var body: some View {
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.lg) {
                Text("Today's Timeline")
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                // Completed activities
                if !todayActivities.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(todayActivities.enumerated()), id: \.element.id) { index, activity in
                            TimelineItemView(
                                activity: activity,
                                isLast: index == todayActivities.count - 1 && upcomingReminders.isEmpty
                            )
                            .onTapGesture {
                                selectedActivity = activity
                            }
                            .contextMenu {
                                Button {
                                    selectedActivity = activity
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    deleteActivity(activity)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                } else {
                    EmptyTimelineView()
                }
                
                // Upcoming Reminders
                if !upcomingReminders.isEmpty {
                    Divider()
                        .padding(.vertical, PawRoutineTheme.Spacing.sm)
                    
                    Text("Upcoming")
                        .font(PawRoutineTheme.PRFont.caption(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        .padding(.bottom, PawRoutineTheme.Spacing.sm)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(upcomingReminders.enumerated()), id: \.offset) { index, reminder in
                            UpcomingReminderRow(
                                time: reminder.0,
                                title: reminder.1,
                                activityType: reminder.2,
                                isLast: index == upcomingReminders.count - 1
                            )
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedActivity) { activity in
            EditActivityView(activity: activity, pet: pet)
        }
    }
    
    private func deleteActivity(_ activity: Activity) {
        if let index = pet.activities.firstIndex(where: { $0.id == activity.id }) {
            pet.activities.remove(at: index)
        }
        modelContext.delete(activity)
        try? modelContext.save()
    }
}

struct TimelineItemView: View {
    let activity: Activity
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: PawRoutineTheme.Spacing.md) {
            // Time column with line
            VStack(spacing: 0) {
                Circle()
                    .fill(PawRoutineTheme.Colors.walking)
                    .frame(width: 8, height: 8)
                    .padding(.top, 16)
                
                if !isLast {
                    Rectangle()
                        .fill(PawRoutineTheme.Colors.separator)
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 24, alignment: .top)
            
            // Content
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.timestamp, format: .dateTime.hour().minute())
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    
                    HStack(spacing: 6) {
                        ActivityTypeIcon(type: activity.type, size: 20)
                        
                        Text(activity.type.displayName)
                            .font(PawRoutineTheme.PRFont.bodyText(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    }
                    
                    if let notes = activity.notes, !notes.isEmpty {
                        Text(notes)
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(PawRoutineTheme.Colors.walking)
            }
            .padding(.vertical, PawRoutineTheme.Spacing.md)
        }
        .frame(minHeight: 56)
    }
}

struct UpcomingReminderRow: View {
    let time: String
    let title: LocalizedStringKey
    let activityType: ActivityType
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: PawRoutineTheme.Spacing.md) {
            // Time column with line
            VStack(spacing: 0) {
                Circle()
                    .stroke(PawRoutineTheme.Colors.textTertiary.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 8, height: 8)
                    .padding(.top, 16)
                
                if !isLast {
                    Rectangle()
                        .fill(PawRoutineTheme.Colors.separator)
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 24, alignment: .top)
            
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(time)
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    
                    HStack(spacing: 6) {
                        ActivityTypeIcon(type: activityType, size: 20)
                        
                        Text(title)
                            .font(PawRoutineTheme.PRFont.bodyText(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Text("Reminder")
                    .font(PawRoutineTheme.PRFont.caption2(.semibold))
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(PawRoutineTheme.Colors.primary.opacity(0.1), in: Capsule())
            }
            .padding(.vertical, PawRoutineTheme.Spacing.md)
        }
        .frame(minHeight: 56)
    }
}

struct EmptyTimelineView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: PawRoutineTheme.Spacing.md) {
                Image(systemName: "clock")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
                
                Text("No activities recorded today")
                    .font(PawRoutineTheme.PRFont.bodyText(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                
                Text("Tap the + button to start recording")
                    .font(PawRoutineTheme.PRFont.caption())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            .padding(.vertical, PawRoutineTheme.Spacing.xxl)
            Spacer()
        }
    }
}

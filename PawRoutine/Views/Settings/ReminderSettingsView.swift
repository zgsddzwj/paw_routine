//
//  ReminderSettingsView.swift
//  PawRoutine
//
//  提醒设置详情页
//

import SwiftUI
import SwiftData

struct ReminderSettingsView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            Form {
                Section(header: Text("Daily Feeding")) {
                    DatePicker("Breakfast Time", selection: $settings.morningFeedingTime, displayedComponents: .hourAndMinute)
                    DatePicker("Dinner Time", selection: $settings.eveningFeedingTime, displayedComponents: .hourAndMinute)
                    Toggle("Enable Reminders", isOn: $settings.feedingReminderEnabled)
                }
                
                Section(header: Text("Walking")) {
                    DatePicker("Morning Walk", selection: $settings.morningWalkTime, displayedComponents: .hourAndMinute)
                    DatePicker("Evening Walk", selection: $settings.eveningWalkTime, displayedComponents: .hourAndMinute)
                    Toggle("Enable Reminders", isOn: $settings.walkReminderEnabled)
                }
                
                Section(header: Text("Water Change")) {
                    DatePicker("Water Change Time", selection: $settings.waterChangeTime, displayedComponents: .hourAndMinute)
                    Toggle("Enable Reminders", isOn: $settings.waterReminderEnabled)
                }
                
                Section(header: Text("Health Reminders")) {
                    HStack {
                        Text("Internal Deworming Interval")
                        Spacer()
                        Picker("", selection: $settings.dewormInternalInterval) {
                            Text("30 days").tag(30)
                            Text("60 days").tag(60)
                            Text("90 days").tag(90)
                            Text("180 days").tag(180)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                    
                    HStack {
                        Text("External Deworming Interval")
                        Spacer()
                        Picker("", selection: $settings.dewormExternalInterval) {
                            Text("30 days").tag(30)
                            Text("60 days").tag(60)
                            Text("90 days").tag(90)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                    
                    Toggle("Vaccine Reminder", isOn: $settings.medicationReminderEnabled)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Reminder Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        try? modelContext.save()
                        // Reschedule daily reminders for all pets when settings change
                        NotificationManager.shared.rescheduleDailyReminders(for: pets, settings: settings)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        }
    }
}

//
//  AddMedicalRecordView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddMedicalRecordView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var recordType = MedicalRecordType.vaccination
    @State private var title = ""
    @State private var date = Date()
    @State private var nextDueDate: Date?
    @State private var notes = ""
    @State private var veterinarian = ""
    @State private var hasNextDueDate = false
    @State private var isReminderSet = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Record Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("记录类型")
                            .font(.headline)
                        
                        Picker("记录类型", selection: $recordType) {
                            ForEach(MedicalRecordType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.systemImage)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("记录名称（如：狂犬疫苗）", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("记录日期")
                            .font(.headline)
                        
                        DatePicker("日期", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Next Due Date (Optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("设置下次提醒", isOn: $hasNextDueDate)
                            .font(.headline)
                        
                        Toggle("开启提醒通知", isOn: $isReminderSet)
                        
                        if hasNextDueDate {
                            DatePicker(
                                "下次日期",
                                selection: Binding(
                                    get: { nextDueDate ?? Calendar.current.date(byAdding: .month, value: 1, to: date) ?? Date() },
                                    set: { nextDueDate = $0 }
                                ),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Veterinarian
                    VStack(alignment: .leading, spacing: 12) {
                        Text("兽医/医院")
                            .font(.headline)
                        
                        TextField("可选", text: $veterinarian)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("备注")
                            .font(.headline)
                        
                        TextField("添加备注信息...", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Photo Upload (for certificates)
                    if recordType == .certificate {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("上传照片")
                                .font(.headline)
                            
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                if let imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                        .cornerRadius(12)
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.blue)
                                        
                                        Text("点击选择照片")
                                            .font(.body)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("添加医疗记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    private func saveRecord() {
        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? recordType.rawValue
            : title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let record = MedicalRecord(
            type: recordType,
            title: finalTitle,
            date: date,
            nextDueDate: hasNextDueDate ? nextDueDate : nil,
            veterinarian: veterinarian.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : veterinarian.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isReminderSet: isReminderSet
        )
        
        record.imageData = imageData
        record.pet = pet
        pet.medicalRecords.append(record)
        
        modelContext.insert(record)
        
        // Schedule notification if next due date is set and reminder is enabled
        if isReminderSet, let nextDueDate = record.nextDueDate {
            scheduleNotification(for: record, date: nextDueDate)
        }
        
        dismiss()
    }
    
    private func scheduleNotification(for record: MedicalRecord, date: Date) {
        if record.type == .vaccination || record.type == .dewormingInternal || record.type == .dewormingExternal {
            // Schedule medical reminder
            NotificationManager.shared.scheduleMedicalReminder(for: record, pet: pet)
        } else {
            // Generic reminder
            let content = UNMutableNotificationContent()
            content.title = "宠物医疗提醒"
            content.body = "\(pet.name) 需要进行 \(record.type.rawValue)"
            content.sound = .default
            
            let calendar = Calendar.current
            let triggerDate = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: date)) ?? date
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let petIDString = pet.persistentModelID.hashValue.description
            let recordIDString = record.persistentModelID.hashValue.description
            let identifier = "medical_\(recordIDString)_\(petIDString)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    print("Scheduled medical reminder for \(pet.name)")
                }
            }
        }
    }
}
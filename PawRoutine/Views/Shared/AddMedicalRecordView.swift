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
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Record Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Record Type")
                            .font(.headline)
                        
                        Picker("Record Type", selection: $recordType) {
                            ForEach(MedicalRecordType.allCases, id: \.self) { type in
                                Label(type.displayName, systemImage: type.systemImage)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Record name (e.g. Rabies vaccine)", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Record Date")
                            .font(.headline)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Next Due Date (Optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Set Next Reminder", isOn: $hasNextDueDate)
                            .font(.headline)
                        
                        Toggle("Enable Reminder Notifications", isOn: $isReminderSet)
                        
                        if hasNextDueDate {
                            DatePicker(
                                "Next Due Date",
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
                        Text("Veterinarian/Hospital")
                            .font(.headline)
                        
                        TextField("Optional", text: $veterinarian)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextField("Add notes...", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Photo Upload (for certificates)
                    if recordType == .certificate {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upload Photo")
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
                                        
                                        Text("Tap to select photo")
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
            .navigationTitle("Add Medical Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
    }
    
    private func saveRecord() {
        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? recordType.displayName
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
            content.title = NSLocalizedString("Pet Medical Reminder", comment: "")
            content.body = String(format: NSLocalizedString("%@ 需要进行 %@", comment: ""), pet.name, record.type.displayName)
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
                    #if DEBUG
                    print("Failed to schedule notification: \(error.localizedDescription)")
                    #endif
                }
            }
        }
    }
}
//
//  EditMedicalRecordView.swift
//  PawRoutine
//
//  编辑医疗记录
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditMedicalRecordView: View {
    let record: MedicalRecord
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: MedicalRecordType
    @State private var title: String
    @State private var date: Date
    @State private var hasNextDueDate: Bool
    @State private var nextDueDate: Date
    @State private var veterinarian: String
    @State private var notes: String
    @State private var isReminderSet: Bool
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingDeleteAlert = false
    
    init(record: MedicalRecord, pet: Pet) {
        self.record = record
        self.pet = pet
        _selectedType = State(initialValue: record.type)
        _title = State(initialValue: record.title)
        _date = State(initialValue: record.date)
        _hasNextDueDate = State(initialValue: record.nextDueDate != nil)
        _nextDueDate = State(initialValue: record.nextDueDate ?? Date().addingTimeInterval(30*24*3600))
        _veterinarian = State(initialValue: record.veterinarian ?? "")
        _notes = State(initialValue: record.notes ?? "")
        _isReminderSet = State(initialValue: record.isReminderSet)
        _imageData = State(initialValue: record.imageData)
    }
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(MedicalRecordType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.systemImage).tag(type)
                        }
                    }
                    
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Next Reminder")) {
                    Toggle("Set Next Date", isOn: $hasNextDueDate)
                    if hasNextDueDate {
                        DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
                        Toggle("Enable Reminders", isOn: $isReminderSet)
                    }
                }
                
                Section(header: Text("Other Info")) {
                    TextField("Veterinarian/Hospital", text: $veterinarian)
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
                
                Section(header: Text("Photos")) {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Change Photo", systemImage: "photo")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Record")
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Medical Record")
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
            .alert("Confirm Delete", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteRecord()
                }
            } message: {
                Text("This action cannot be undone")
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
        }
    }
    
    private func saveRecord() {
        record.type = selectedType
        record.title = title.isEmpty ? selectedType.displayName : title
        record.date = date
        record.nextDueDate = hasNextDueDate ? nextDueDate : nil
        record.veterinarian = veterinarian.isEmpty ? nil : veterinarian
        record.notes = notes.isEmpty ? nil : notes
        record.isReminderSet = isReminderSet && hasNextDueDate
        record.imageData = imageData
        
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteRecord() {
        if let index = pet.medicalRecords.firstIndex(where: { $0.id == record.id }) {
            pet.medicalRecords.remove(at: index)
        }
        modelContext.delete(record)
        try? modelContext.save()
        dismiss()
    }
}

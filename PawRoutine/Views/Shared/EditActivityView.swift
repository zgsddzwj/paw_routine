//
//  EditActivityView.swift
//  PawRoutine
//
//  编辑/删除活动记录
//

import SwiftUI
import SwiftData

struct EditActivityView: View {
    let activity: Activity
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: ActivityType
    @State private var timestamp: Date
    @State private var notes: String
    @State private var duration: String
    @State private var showingDeleteAlert = false
    
    init(activity: Activity, pet: Pet) {
        self.activity = activity
        self.pet = pet
        _selectedType = State(initialValue: activity.type)
        _timestamp = State(initialValue: activity.timestamp)
        _notes = State(initialValue: activity.notes ?? "")
        _duration = State(initialValue: activity.duration != nil ? "\(activity.duration!)" : "")
    }
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            Form {
                Section(header: Text("Activity Type")) {
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        Button(action: { selectedType = type }) {
                            HStack(spacing: PawRoutineTheme.Spacing.md) {
                                ActivityTypeIcon(type: type, size: 24)
                                Text(type.displayName)
                                    .font(PawRoutineTheme.PRFont.bodyText())
                                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                Spacer()
                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(PawRoutineTheme.Colors.walking)
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Date & Time", selection: $timestamp)
                }
                
                Section(header: Text("Duration (min, optional)")) {
                    TextField("e.g. 30", text: $duration)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
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
            .navigationTitle("Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveActivity()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedType.rawValue.isEmpty)
                }
            }
            .alert("Confirm Delete", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteActivity()
                }
            } message: {
                Text("This action cannot be undone")
            }
        }
        }
    }
    
    private func saveActivity() {
        activity.type = selectedType
        activity.timestamp = timestamp
        activity.notes = notes.isEmpty ? nil : notes
        activity.duration = Int(duration)
        
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteActivity() {
        if let index = pet.activities.firstIndex(where: { $0.id == activity.id }) {
            pet.activities.remove(at: index)
        }
        modelContext.delete(activity)
        try? modelContext.save()
        dismiss()
    }
}

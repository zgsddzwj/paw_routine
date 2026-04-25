//
//  CustomActivityView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI

struct CustomActivityView: View {
    let activityType: ActivityType
    @Binding var customTime: Date
    @Binding var notes: String
    let onSave: (ActivityType, Date, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNotesFieldFocused: Bool
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            VStack(spacing: 24) {
                // Activity Type Header
                VStack(spacing: 12) {
                    ActivityTypeIcon(type: activityType, size: 60)
                    
                    Text(activityType.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top)
                
                // Time Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    DatePicker(
                        "Select Time",
                        selection: $customTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes (Optional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .focused($isNotesFieldFocused)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                // Save Button
                Button(action: save) {
                    Text("Save Record")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .navigationTitle("Custom Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        }
    }
    
    private func save() {
        let finalNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(activityType, customTime, finalNotes.isEmpty ? nil : finalNotes)
        dismiss()
    }
}
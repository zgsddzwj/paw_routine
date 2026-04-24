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
        NavigationView {
            VStack(spacing: 24) {
                // Activity Type Header
                VStack(spacing: 12) {
                    Text(activityType.icon)
                        .font(.system(size: 60))
                    
                    Text(activityType.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top)
                
                // Time Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("时间")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    DatePicker(
                        "选择时间",
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
                    Text("备注 (可选)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("添加备注...", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .focused($isNotesFieldFocused)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                // Save Button
                Button(action: save) {
                    Text("保存记录")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .navigationTitle("自定义记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        save()
                    }
                    .fontWeight(.semibold)
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
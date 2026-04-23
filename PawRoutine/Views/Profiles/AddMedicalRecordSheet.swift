//
//  AddMedicalRecordSheet.swift
//  PawRoutine
//
//  添加医疗记录 - 设计稿还原
//

import SwiftUI
import SwiftData

struct AddMedicalRecordSheet: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var medicalType: MedicalType = .vaccination
    @State private var title = ""
    @State private var date = Date()
    @State private var nextDueDate: Date?
    @State private var veterinarian = ""
    @State private var note = ""
    @State private var isReminderSet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("类型") {
                    Picker("医疗类型", selection: $medicalType) {
                        ForEach(MedicalType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("基本信息") {
                    TextField("标题（如：狂犬疫苗）", text: $title)
                    
                    DatePicker(
                        "日期",
                        selection: $date,
                        displayedComponents: .date
                    )
                    
                    Toggle("设置下次提醒", isOn: $isReminderSet)
                    
                    if isReminderSet {
                        DatePicker(
                            "下次日期",
                            selection: Binding(
                                get: { nextDueDate ?? Calendar.current.date(byAdding: .day, value: medicalType.defaultReminderInterval ?? 30, to: Date()) ?? Date() },
                                set: { nextDueDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
                
                Section("详情（可选）") {
                    TextField("兽医/医院名称", text: $veterinarian)
                    TextField("备注信息", text: $note, axis: .vertical)
                        .lineLimit(2...6)
                }
            }
            .navigationTitle("添加医疗记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        
                        let record = MedicalRecord(
                            medicalType: medicalType,
                            title: title.trimmingCharacters(in: .whitespaces),
                            date: date,
                            nextDueDate: isReminderSet ? (nextDueDate ?? nil) : nil,
                            veterinarian: veterinarian.isEmpty ? nil : veterinarian,
                            note: note.isEmpty ? nil : note,
                            isReminderSet: isReminderSet
                        )
                        record.pet = pet
                        modelContext.insert(record)
                        
                        if isReminderSet, let dueDate = nextDueDate {
                            NotificationManager.shared.scheduleMedicalReminder(for: pet, title: title, date: dueDate)
                        }
                        
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

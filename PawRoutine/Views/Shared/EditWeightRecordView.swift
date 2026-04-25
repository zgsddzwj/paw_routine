//
//  EditWeightRecordView.swift
//  PawRoutine
//
//  编辑体重记录
//

import SwiftUI
import SwiftData

struct EditWeightRecordView: View {
    let record: WeightRecord
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: String
    @State private var date: Date
    @State private var notes: String
    @State private var showingDeleteAlert = false
    
    init(record: WeightRecord, pet: Pet) {
        self.record = record
        self.pet = pet
        _weight = State(initialValue: String(format: "%.1f", record.weight))
        _date = State(initialValue: record.date)
        _notes = State(initialValue: record.notes ?? "")
    }
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            Form {
                Section(header: Text("Weight")) {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Record Date", selection: $date, displayedComponents: .date)
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
            .navigationTitle("Edit Weight Record")
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
        }
        }
    }
    
    private func saveRecord() {
        guard let weightValue = Double(weight), weightValue > 0 else { return }
        record.weight = weightValue
        record.date = date
        record.notes = notes.isEmpty ? nil : notes
        
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteRecord() {
        if let index = pet.weightRecords.firstIndex(where: { $0.id == record.id }) {
            pet.weightRecords.remove(at: index)
        }
        modelContext.delete(record)
        try? modelContext.save()
        dismiss()
    }
}

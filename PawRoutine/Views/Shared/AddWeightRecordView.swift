//
//  AddWeightRecordView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData

struct AddWeightRecordView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: Double = 0.0
    @State private var date = Date()
    @State private var notes = ""
    @State private var weightText = ""
    
    var canSave: Bool {
        weight > 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Weight Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("体重")
                            .font(.headline)
                        
                        HStack {
                            TextField("0.0", text: $weightText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: weightText) { _, newValue in
                                    weight = Double(newValue) ?? 0.0
                                }
                            
                            Text("kg")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("测量日期")
                            .font(.headline)
                        
                        DatePicker("日期", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("备注 (可选)")
                            .font(.headline)
                        
                        TextField("添加备注信息...", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Previous Records Summary
                    if !pet.weightRecords.isEmpty {
                        PreviousWeightSummaryView(pet: pet, currentWeight: weight)
                    }
                }
                .padding()
            }
            .navigationTitle("记录体重")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveWeightRecord()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            // Pre-fill with last weight if available
            if let lastRecord = pet.weightRecords.sorted(by: { $0.date > $1.date }).first {
                weightText = String(format: "%.1f", lastRecord.weight)
                weight = lastRecord.weight
            }
        }
    }
    
    private func saveWeightRecord() {
        let record = WeightRecord(
            weight: weight,
            date: date,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        record.pet = pet
        pet.weightRecords.append(record)
        
        modelContext.insert(record)
        dismiss()
    }
}

struct PreviousWeightSummaryView: View {
    let pet: Pet
    let currentWeight: Double
    
    private var lastRecord: WeightRecord? {
        pet.weightRecords.sorted(by: { $0.date > $1.date }).first
    }
    
    private var weightChange: Double? {
        guard let lastWeight = lastRecord?.weight, currentWeight > 0 else { return nil }
        return currentWeight - lastWeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("体重对比")
                .font(.headline)
            
            if let lastRecord = lastRecord {
                VStack(spacing: 8) {
                    HStack {
                        Text("上次记录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f kg", lastRecord.weight))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("记录时间")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(lastRecord.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let change = weightChange, currentWeight > 0 {
                        HStack {
                            Text("体重变化")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption)
                                    .foregroundColor(change >= 0 ? .green : .red)
                                
                                Text(String(format: "%.1f kg", abs(change)))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(change >= 0 ? .green : .red)
                            }
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
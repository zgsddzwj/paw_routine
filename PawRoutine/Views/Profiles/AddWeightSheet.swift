//
//  AddWeightSheet.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import SwiftData

struct AddWeightSheet: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var weightString = ""
    @State private var note = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("体重 (kg)") {
                    TextField("输入体重", text: $weightString)
                        .keyboardType(.decimalPad)
                }
                
                Section("备注（可选）") {
                    TextField("如：最近食欲不错", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("记录体重")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        guard let weight = Double(weightString), weight > 0 else { return }
                        
                        let record = WeightRecord(
                            weight: weight,
                            note: note.isEmpty ? nil : note
                        )
                        record.pet = pet
                        modelContext.insert(record)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(weightString.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

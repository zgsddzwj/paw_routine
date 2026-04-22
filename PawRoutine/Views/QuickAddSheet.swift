//
//  QuickAddSheet.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import SwiftData

struct QuickAddSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isPresented: Bool
    @Query(sort: \Pet.sortOrder) private var pets: [Pet]
    
    @State private var selectedPetIndex: Int = 0
    @State private var showDetailEditor = false
    @State private var selectedType: RecordType?
    @State private var editingTime = Date()
    @State private var editingNote = ""
    
    // 按钮网格布局列数
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // MARK: - 宠物选择器（多宠物时显示）
                if pets.count > 1 {
                    petSelector
                }
                
                // MARK: - 快捷操作按钮网格
                actionGrid
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .navigationTitle("快速记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showDetailEditor) {
            if let type = selectedType {
                RecordDetailEditor(
                    recordType: type,
                    selectedTime: $editingTime,
                    note: $editingNote,
                    onSave: { saveRecord(type: type) },
                    onCancel: { showDetailEditor = false }
                )
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
            }
        }
        .onAppear {
            // 默认选中第一只宠物
            selectedPetIndex = min(selectedPetIndex, max(pets.count - 1, 0))
        }
    }
    
    // MARK: - Pet Selector
    
    private var petSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(pets.enumerated()), id: \.element.id) { index, pet in
                    Button {
                        selectedPetIndex = index
                    } label: {
                        VStack(spacing: 4) {
                            if let avatar = pet.avatarImage {
                                avatar
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(PawRoutineTheme.Colors.primary.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: pet.petType.icon)
                                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                                    )
                            }
                            
                            Text(pet.name)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(selectedPetIndex == index ? .primary : .secondary)
                        }
                    }
                    .opacity(selectedPetIndex == index ? 1.0 : 0.6)
                }
            }
        }
    }
    
    // MARK: - Action Grid
    
    private var actionGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(RecordType.allCases) { type in
                quickActionButton(for: type)
            }
        }
    }
    
    private func quickActionButton(for type: RecordType) -> some View {
        Button {
            // 短按直接记录
            quickAddRecord(type: type)
        } label: {
            VStack(spacing: 12) {
                // 图标圆圈
                ZStack {
                    Circle()
                        .fill(colorFor(type).opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Text(type.emoji)
                        .font(.system(size: 28))
                }
                .shadow(color: colorFor(type).opacity(0.2), radius: 8, y: 4)
                
                // 标签
                Text(type.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.5) {
            // 长按打开详细编辑器
            selectedType = type
            editingTime = Date()
            editingNote = ""
            showDetailEditor = true
        }
    }
    
    // MARK: - Actions
    
    private func colorFor(_ type: RecordType) -> Color {
        switch type {
        case .feeding: return PawRoutineTheme.Colors.feeding
        case .water: return PawRoutineTheme.Colors.water
        case .walking: return PawRoutineTheme.Colors.walking
        case .medication: return PawRoutineTheme.Colors.medication
        case .bathroom: return PawRoutineTheme.Colors.bathroom
        }
    }
    
    /// 快速添加记录（短按，使用当前时间）
    private func quickAddRecord(type: RecordType) {
        guard !pets.isEmpty else { return }
        
        let record = DailyRecord(recordType: type, timestamp: Date())
        record.pet = pets[selectedPetIndex]
        modelContext.insert(record)
        
        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        dismiss()
    }
    
    /// 带详情的添加记录（长按后保存）
    private func saveRecord(type: RecordType) {
        guard !pets.isEmpty else { return }
        
        let record = DailyRecord(
            recordType: type,
            timestamp: editingTime,
            note: editingNote.isEmpty ? nil : editingNote
        )
        record.pet = pets[selectedPetIndex]
        modelContext.insert(record)
        
        showDetailEditor = false
        dismiss()
    }
}

// MARK: - Record Detail Editor

struct RecordDetailEditor: View {
    let recordType: RecordType
    @Binding var selectedTime: Date
    @Binding var note: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("时间") {
                    DatePicker(
                        "记录时间",
                        selection: $selectedTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                }
                
                Section("备注") {
                    TextField("添加备注（可选）", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("\(recordType.emoji) \(recordType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", role: .cancel, action: onCancel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存", action: onSave)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    QuickAddSheet(isPresented: .constant(true))
        .modelContainer(for: Pet.self, inMemory: true)
}

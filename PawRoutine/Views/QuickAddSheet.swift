//
//  QuickAddSheet.swift
//  PawRoutine
//
//  快速记录面板 - 设计稿还原
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
            VStack(spacing: PawRoutineTheme.Spacing.xl) {
                // MARK: - 宠物选择器（多宠物时显示）
                if pets.count > 1 {
                    petSelector
                }
                
                // MARK: - 快捷操作按钮网格
                actionGrid
                
                Spacer()
                
                // 底部提示文字
                Text("长按可修改时间或添加备注")
                    .font(PawRoutineTheme.PRFont.caption())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.xxl)
            .padding(.top, PawRoutineTheme.Spacing.md)
            .navigationTitle("快速记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .font(PawRoutineTheme.PRFont.bodyText(.medium))
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
                .presentationBackground(PawRoutineTheme.Colors.bgPrimary)
            }
        }
        .onAppear {
            selectedPetIndex = min(selectedPetIndex, max(pets.count - 1, 0))
        }
    }
    
    // MARK: - Pet Selector (紧凑版)
    
    private var petSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                ForEach(Array(pets.enumerated()), id: \.element.id) { index, pet in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPetIndex = index
                        }
                    } label: {
                        HStack(spacing: 6) {
                            PRPetAvatar(image: pet.avatarImage, size: 32)
                            
                            Text(pet.name)
                                .font(PawRoutineTheme.PRFont.caption(selectedPetIndex == index ? .semibold : .regular))
                                .foregroundStyle(selectedPetIndex == index ? PawRoutineTheme.Colors.textPrimary : PawRoutineTheme.Colors.textTertiary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.full)
                                .fill(selectedPetIndex == index ? PawRoutineTheme.Colors.primary.opacity(0.08) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.full)
                                        .stroke(selectedPetIndex == index ? PawRoutineTheme.Colors.primary.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Action Grid
    
    private var actionGrid: some View {
        LazyVGrid(columns: columns, spacing: PawRoutineTheme.Spacing.xl) {
            ForEach(RecordType.allCases) { type in
                quickActionButton(for: type)
            }
        }
        .padding(.vertical, PawRoutineTheme.Spacing.sm)
    }
    
    private func quickActionButton(for type: RecordType) -> some View {
        Button {
            quickAddRecord(type: type)
        } label: {
            VStack(spacing: 10) {
                // 图标圆圈
                ZStack {
                    Circle()
                        .fill(colorFor(type).opacity(0.10))
                        .frame(width: 64, height: 64)
                    
                    Text(type.emoji)
                        .font(.system(size: 28))
                }
                .shadow(color: colorFor(type).opacity(0.15), radius: 6, y: 3)
                
                Text(type.rawValue)
                    .font(PawRoutineTheme.PRFont.caption(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
            }
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.5) {
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
    
    private func quickAddRecord(type: RecordType) {
        guard !pets.isEmpty else { return }
        
        let record = DailyRecord(recordType: type, timestamp: Date())
        record.pet = pets[selectedPetIndex]
        modelContext.insert(record)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        dismiss()
    }
    
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
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 类型图标 + 名称
                HStack(spacing: PawRoutineTheme.Spacing.md) {
                    Circle()
                        .fill(colorFor(recordType).opacity(0.10))
                        .frame(width: 44, height: 44)
                        .overlay(Text(recordType.emoji).font(.title3))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recordType.rawValue)
                            .font(PawRoutineTheme.PRFont.title3(.semibold))
                        
                        Text("遛狗")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    PRTag(text: "已提醒", color: PawRoutineTheme.Colors.secondary)
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                
                Divider()
                
                // 时间选择
                VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
                    Text("时间")
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    HStack {
                        Text("今天")
                            .font(PawRoutineTheme.PRFont.bodyText())
                        
                        Spacer()
                        
                        Text(selectedTime, format: .dateTime.hour().minute())
                            .font(PawRoutineTheme.PRFont.bodyText(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                    .padding(.vertical, 12)
                    .background(PawRoutineTheme.Colors.bgSecondary, in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                
                // 备注
                VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
                    Text("备注")
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    TextField("今天状态很好，跑得很开心！", text: $note, axis: .vertical)
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .lineLimit(2...4)
                        .padding(12)
                        .background(PawRoutineTheme.Colors.bgSecondary, in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                
                Spacer()
                
                // 保存按钮
                Button(action: onSave) {
                    Text("保存")
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [
                                    PawRoutineTheme.Colors.primary,
                                    PawRoutineTheme.Colors.primary.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md)
                        )
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.bottom, PawRoutineTheme.Spacing.md)
            }
            .navigationTitle("\(recordType.emoji) \(recordType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", role: .cancel, action: onCancel)
                        .font(PawRoutineTheme.PRFont.bodyText())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成", action: onSave)
                        .font(PawRoutineTheme.PRFont.bodyText(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
            }
        }
    }
    
    private func colorFor(_ type: RecordType) -> Color {
        switch type {
        case .feeding: return PawRoutineTheme.Colors.feeding
        case .water: return PawRoutineTheme.Colors.water
        case .walking: return PawRoutineTheme.Colors.walking
        case .medication: return PawRoutineTheme.Colors.medication
        case .bathroom: return PawRoutineTheme.Colors.bathroom
        }
    }
}

#Preview {
    QuickAddSheet(isPresented: .constant(true))
        .modelContainer(for: Pet.self, inMemory: true)
}

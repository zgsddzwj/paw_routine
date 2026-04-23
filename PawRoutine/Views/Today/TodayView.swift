//
//  TodayView.swift
//  PawRoutine
//
//  今日看板 - 设计稿还原
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pet.sortOrder) private var pets: [Pet]
    
    @State private var selectedPetIndex: Int = 0
    
    private var selectedPet: Pet? {
        guard !pets.isEmpty, selectedPetIndex < pets.count else { return nil }
        return pets[selectedPetIndex]
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let pet = selectedPet {
                    todayContent(for: pet)
                } else {
                    PREmptyState(
                        icon: "pawprint.circle.fill",
                        title: "还没有宠物档案",
                        subtitle: "点击右上角添加你的第一只宠物吧！"
                    )
                }
            }
            .navigationTitle("今日看板")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AddPetView()) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private func todayContent(for pet: Pet) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 宠物切换器
                PetSelectorRow(
                    pets: pets,
                    selectedIndex: $selectedPetIndex,
                    onAddTapped: { /* handled by toolbar */ }
                )
                
                // 今日进度环
                DailyProgressRings(pet: pet)
                
                // 时间轴列表
                TimelineSection(pet: pet)
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
    }
}

// MARK: - Pet Selector Row (设计稿顶部宠物切换)

struct PetSelectorRow: View {
    let pets: [Pet]
    @Binding var selectedIndex: Int
    let onAddTapped: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                ForEach(Array(pets.enumerated()), id: \.element.id) { index, pet in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedIndex = index
                        }
                    } label: {
                        VStack(spacing: 6) {
                            PRPetAvatar(
                                image: pet.avatarImage,
                                size: 56,
                                isSelected: index == selectedIndex,
                                showBorder: true
                            )
                            
                            Text(pet.name)
                                .font(PawRoutineTheme.Font.caption2(index == selectedIndex ? .semibold : .regular))
                                .foregroundStyle(index == selectedIndex ? PawRoutineTheme.Colors.textPrimary : PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // 添加按钮
                Button {
                    onAddTapped()
                } label: {
                    VStack(spacing: 6) {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.6))
                            )
                        
                        Text("添加")
                            .font(PawRoutineTheme.Font.caption2())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, PawRoutineTheme.Spacing.sm)
        }
    }
}

// MARK: - Daily Progress Rings (设计稿三圆环)

struct DailyProgressRings: View {
    let pet: Pet
    
    private var todayRecords: [DailyRecord] { pet.todayRecords }
    
    private func progress(for type: RecordType) -> Double {
        let count = todayRecords.filter { $0.recordType == type }.count
        return min(Double(count) / Double(type.defaultDailyGoal), 1.0)
    }
    
    private func count(for type: RecordType) -> Int {
        todayRecords.filter { $0.recordType == type }.count
    }
    
    var body: some View {
        PRCard(padding: .init(top: 20, leading: 16, bottom: 16, trailing: 16)) {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.lg) {
                // 标题行 + 编辑按钮
                HStack {
                    PRSectionHeader("今日进度")
                    
                    Spacer()
                    
                    Button("编辑") {
                        // TODO: 编辑目标
                    }
                    .font(PawRoutineTheme.Font.caption(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
                
                // 三圆环
                HStack(spacing: PawRoutineTheme.Spacing.xl) {
                    PRProgressRing(
                        progress: progress(for: .feeding),
                        total: RecordType.feeding.defaultDailyGoal,
                        current: count(for: .feeding),
                        color: PawRoutineTheme.Colors.feeding,
                        label: "喂食"
                    )
                    
                    PRProgressRing(
                        progress: progress(for: .walking),
                        total: RecordType.walking.defaultDailyGoal,
                        current: count(for: .walking),
                        color: PawRoutineTheme.Colors.walking,
                        label: "遛狗"
                    )
                    
                    PRProgressRing(
                        progress: progress(for: .bathroom),
                        total: RecordType.bathroom.defaultDailyGoal,
                        current: count(for: .bathroom),
                        color: PawRoutineTheme.Colors.bathroom,
                        label: "排便"
                    )
                }
                .frame(maxWidth: .infinity)
                
                // 完成度提示
                HStack(spacing: 4) {
                    Text("目前完成度")
                        .font(PawRoutineTheme.Font.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    let totalGoal = RecordType.feeding.defaultDailyGoal + RecordType.walking.defaultDailyGoal + RecordType.bathroom.defaultDailyGoal
                    let totalDone = count(for: .feeding) + count(for: .walking) + count(for: .bathroom)
                    let pct = totalGoal > 0 ? Int(Double(totalDone) / Double(totalGoal) * 100) : 0
                    
                    Text("\(pct)%")
                        .font(PawRoutineTheme.Font.caption(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.feeding)
                    
                    Image(systemName: "face.smiling")
                        .font(.caption2)
                        .foregroundStyle(PawRoutineTheme.Colors.feeding)
                }
            }
        }
    }
}

// MARK: - Timeline Section (设计稿时间轴)

struct TimelineSection: View {
    let pet: Pet
    
    private var sortedRecords: [DailyRecord] {
        pet.todayRecords.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        PRCard(padding: .zero) {
            VStack(alignment: .leading, spacing: 0) {
                // 标题
                PRSectionHeader("今日时间轴")
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.lg)
                    .padding(.bottom, PawRoutineTheme.Spacing.md)
                
                if sortedRecords.isEmpty {
                    VStack(spacing: PawRoutineTheme.Spacing.md) {
                        Image(systemName: "text.line.first.trailing.arrow.backward.normal")
                            .font(.title2)
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
                        
                        Text("今天还没有记录")
                            .font(PawRoutineTheme.Font.bodyText())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        
                        Text("点击右下角 + 快速记录")
                            .font(PawRoutineTheme.Font.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                } else {
                    ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                        TimelineItemRow(record: record, isLast: index == sortedRecords.count - 1)
                    }
                }
            }
        }
    }
}

// MARK: - Timeline Item Row

struct TimelineItemRow: View {
    let record: DailyRecord
    let isLast: Bool
    
    private var typeColor: Color {
        switch record.recordType {
        case .feeding: return PawRoutineTheme.Colors.feeding
        case .water: return PawRoutineTheme.Colors.water
        case .walking: return PawRoutineTheme.Colors.walking
        case .medication: return PawRoutineTheme.Colors.medication
        case .bathroom: return PawRoutineTheme.Colors.bathroom
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: PawRoutineTheme.Spacing.md) {
                // 左侧：时间 + 竖线
                VStack(spacing: 0) {
                    Text(record.timestamp, format: .dateTime.hour().minute())
                        .font(PawRoutineTheme.Font.caption2(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        .frame(width: 44, alignment: .trailing)
                    
                    if !isLast {
                        Rectangle()
                            .fill(PawRoutineTheme.Colors.separator)
                            .frame(width: 1)
                    }
                }
                .padding(.top, 3)
                
                // 右侧：内容卡片
                HStack(alignment: .center, spacing: PawRoutineTheme.Spacing.sm) {
                    // 类型图标圆圈
                    Circle()
                        .fill(typeColor.opacity(0.12))
                        .overlay(
                            Text(record.recordType.emoji)
                                .font(.system(size: 14))
                        )
                        .frame(width: 32, height: 32)
                    
                    // 文字信息
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: PawRoutineTheme.Spacing.sm) {
                            Text(record.recordType.rawValue)
                                .font(PawRoutineTheme.Font.bodyText(.medium))
                                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                            
                            if let note = record.note, !note.isEmpty {
                                Text(note)
                                    .font(PawRoutineTheme.Font.caption())
                                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Text("\(record.timestamp, format: .dateTime.hour().minute()) · \(record.timestamp.formatted(.dateTime.month().day()))")
                            .font(PawRoutineTheme.Font.micro())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    // 右侧勾选标记
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(typeColor.opacity(0.5))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, PawRoutineTheme.Spacing.md)
                .background(typeColor.opacity(0.04), in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.vertical, PawRoutineTheme.Spacing.sm)
            
            if !isLast {
                Divider()
                    .padding(.leading, 76)
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Pet.self, inMemory: true)
}

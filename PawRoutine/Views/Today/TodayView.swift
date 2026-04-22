//
//  TodayView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
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
                    emptyStateView
                }
            }
            .navigationTitle("今日")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AddPetView()) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.3))
            
            Text("还没有宠物档案")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text("点击右上角添加你的第一只宠物吧！")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            
            Spacer()
        }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private func todayContent(for pet: Pet) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                // 宠物切换器
                petSelector(currentPet: pet)
                
                // 每日进度环
                DailyRingsView(pet: pet)
                    .padding(.horizontal, 16)
                
                // 时间轴
                TimelineView(pet: pet)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
        .background(
            LinearGradient(
                colors: [PawRoutineTheme.Colors.gradientTop, PawRoutineTheme.Colors.gradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    // MARK: - Pet Selector (Horizontal Scroll)
    
    private func petSelector(currentPet: Pet) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Array(pets.enumerated()), id: \.element.id) { index, pet in
                    Button {
                        selectedPetIndex = index
                    } label: {
                        VStack(spacing: 6) {
                            if let avatar = pet.avatarImage {
                                avatar
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: selectedPetIndex == index ? 60 : 50,
                                           height: selectedPetIndex == index ? 60 : 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedPetIndex == index ? PawRoutineTheme.Colors.primary : Color.clear,
                                                    lineWidth: 3)
                                    )
                                    .shadow(color: selectedPetIndex == index ? PawRoutineTheme.Colors.primary.opacity(0.3) : .clear,
                                            radius: 8, y: 4)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(selectedPetIndex == index ? PawRoutineTheme.Colors.primary.opacity(0.15) : Color.gray.opacity(0.1))
                                        .frame(width: selectedPetIndex == index ? 60 : 50,
                                               height: selectedPetIndex == index ? 60 : 50)
                                    
                                    Text(Image(systemName: pet.petType.icon))
                                        .font(.system(size: selectedPetIndex == index ? 24 : 20))
                                        .foregroundStyle(selectedPetIndex == index ? PawRoutineTheme.Colors.primary : .gray)
                                }
                            }
                            
                            Text(pet.name)
                                .font(.caption2.weight(selectedPetIndex == index ? .semibold : .regular))
                                .foregroundStyle(selectedPetIndex == index ? .primary : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 90)
    }
}

// MARK: - Daily Rings (Apple Watch Style)

struct DailyRingsView: View {
    let pet: Pet
    
    private var todayRecords: [DailyRecord] {
        pet.todayRecords
    }
    
    /// 计算每种记录类型的完成度
    private func progress(for type: RecordType) -> Double {
        let count = todayRecords.filter { $0.recordType == type }.count
        return min(Double(count) / Double(type.defaultDailyGoal), 1.0)
    }
    
    var body: some View {
        GlassCard {
            HStack(spacing: 20) {
                // 三圆环
                ZStack {
                    // 遛狗环（外）
                    RingProgress(
                        progress: progress(for: .walking),
                        color: PawRoutineTheme.Colors.walking,
                        lineWidth: 10,
                        radius: 55
                    )
                    
                    // 喂食环（中）
                    RingProgress(
                        progress: progress(for: .feeding),
                        color: PawRoutineTheme.Colors.feeding,
                        lineWidth: 10,
                        radius: 42
                    )
                    
                    // 排便环（内）
                    RingProgress(
                        progress: progress(for: .bathroom),
                        color: PawRoutineTheme.Colors.bathroom,
                        lineWidth: 10,
                        radius: 29
                    )
                }
                .frame(width: 130, height: 130)
                
                // 图例说明
                VStack(alignment: .leading, spacing: 10) {
                    ringLegendItem(
                        "遛狗",
                        color: PawRoutineTheme.Colors.walking,
                        current: todayRecords.filter { $0.recordType == .walking }.count,
                        goal: RecordType.walking.defaultDailyGoal
                    )
                    ringLegendItem(
                        "喂食",
                        color: PawRoutineTheme.Colors.feeding,
                        current: todayRecords.filter { $0.recordType == .feeding }.count,
                        goal: RecordType.feeding.defaultDailyGoal
                    )
                    ringLegendItem(
                        "排便",
                        color: PawRoutineTheme.Colors.bathroom,
                        current: todayRecords.filter { $0.recordType == .bathroom }.count,
                        goal: RecordType.bathroom.defaultDailyGoal
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func ringLegendItem(_ title: String, color: Color, current: Int, goal: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.subheadline)
                .frame(width: 40, alignment: .leading)
            
            Text("\(current)/\(goal)")
                .font(.caption.weight(.medium))
                .foregroundStyle(current >= goal ? color : .secondary)
        }
    }
}

// MARK: - Single Ring Progress Component

struct RingProgress: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let radius: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // 背景轨道
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            
            // 进度弧线
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.6), color, color.opacity(0.6)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedProgress)
        }
        .frame(width: radius * 2, height: radius * 2)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Timeline View

struct TimelineView: View {
    let pet: Pet
    
    private var sortedRecords: [DailyRecord] {
        pet.todayRecords.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                // 标题行
                HStack {
                    Label("时间轴", systemImage: "clock.arrow.circlepath")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(sortedRecords.count) 条记录")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                
                if sortedRecords.isEmpty {
                    emptyTimeline
                } else {
                    timelineList
                }
            }
        }
    }
    
    private var emptyTimeline: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.line.first.trailing.arrow.backward.normal")
                .font(.title2)
                .foregroundStyle(.tertiary)
            
            Text("今天还没有记录")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("点击右下角 + 快速记录")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    private var timelineList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                TimelineRow(record: record, isLast: index == sortedRecords.count - 1)
            }
        }
    }
}

// MARK: - Timeline Row

struct TimelineRow: View {
    let record: DailyRecord
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 时间轴竖线和圆点
            VStack(spacing: 0) {
                Circle()
                    .fill(colorFor(record.recordType))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 2)
                }
            }
            .padding(.top, 2)
            
            // 内容卡片
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(record.recordType.rawValue)
                        .font(.subheadline.weight(.semibold))
                    
                    Text(record.timestamp, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(record.recordType.emoji)
                        .font(.title3)
                }
                
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(colorFor(record.recordType).opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.bottom, isLast ? 0 : 12)
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
    TodayView()
        .modelContainer(for: Pet.self, inMemory: true)
}

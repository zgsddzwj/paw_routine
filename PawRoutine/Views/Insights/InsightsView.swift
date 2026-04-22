//
//  InsightsView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \Pet.sortOrder) private var pets: [Pet]
    @State private var selectedPetIndex: Int = 0
    @State private var selectedMonth: Date = Date()
    
    private var selectedPet: Pet? {
        guard !pets.isEmpty, selectedPetIndex < pets.count else { return nil }
        return pets[selectedPetIndex]
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let pet = selectedPet {
                    insightsContent(for: pet)
                } else {
                    emptyState
                }
            }
            .navigationTitle("统计")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 80))
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.3))
            
            Text("还没有数据可统计")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text("添加宠物并记录日常活动后，这里会展示统计图表")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private func insightsContent(for pet: Pet) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                // 宠物切换 + 月份选择
                insightsHeader(pet: pet)
                
                // 日历视图
                CalendarMonthView(pet: pet, selectedMonth: $selectedMonth)
                
                // 本周习惯分析
                WeeklyHabitChart(pet: pet)
                
                // 月度汇总
                MonthlySummaryView(pet: pet, month: selectedMonth)
            }
            .padding(.horizontal, 16)
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
    
    // MARK: - Header (Pet Switcher + Month Picker)
    
    private func insightsHeader(pet: Pet) -> some View {
        HStack {
            // 宠物选择器（紧凑版）
            if pets.count > 1 {
                Menu {
                    ForEach(Array(pets.enumerated()), id: \.element.id) { index, p in
                        Button {
                            selectedPetIndex = index
                        } label: {
                            Label(p.name, systemImage: selectedPetIndex == index ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if let avatar = pet.avatarImage {
                            avatar
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(PawRoutineTheme.Colors.primary.opacity(0.15))
                                .frame(width: 28, height: 28)
                        }
                        
                        Text(pet.name)
                            .font(.subheadline.weight(.semibold))
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(.primary)
                }
            } else {
                HStack(spacing: 8) {
                    if let avatar = pet.avatarImage {
                        avatar
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                    
                    Text(pet.name)
                        .font(.headline)
                }
            }
            
            Spacer()
            
            // 月份选择器
            HStack(spacing: 4) {
                Button {
                    withAnimation {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.bold))
                        .frame(width: 30, height: 30)
                        .background(.ultraThinMaterial, in: Circle())
                }
                
                Text(selectedMonth, format: .dateTime.year().month())
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 80)
                
                Button {
                    withAnimation {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .frame(width: 30, height: 30)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: Pet.self, inMemory: true)
}

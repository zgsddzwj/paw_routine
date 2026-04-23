//
//  InsightsView.swift
//  PawRoutine
//
//  统计与回顾 - 设计稿还原
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
                    PREmptyState(
                        icon: "chart.bar.fill",
                        title: "还没有数据可统计",
                        subtitle: "添加宠物并记录日常活动后，这里会展示统计图表"
                    )
                }
            }
            .navigationTitle("统计与回顾")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Empty State
    
    // MARK: - Main Content
    
    @ViewBuilder
    private func insightsContent(for pet: Pet) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 头部：宠物切换 + 月份选择
                insightsHeader(pet: pet)
                
                // 日历视图
                CalendarMonthView(pet: pet, selectedMonth: $selectedMonth)
                
                // 本周习惯分析
                WeeklyHabitChart(pet: pet)
                
                // 月度汇总
                MonthlySummaryView(pet: pet, month: selectedMonth)
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
    }
    
    // MARK: - Header (Pet Switcher + Month Picker)
    
    private func insightsHeader(pet: Pet) -> some View {
        HStack {
            // 宠物选择器（紧凑版）
            if pets.count > 1 {
                Menu {
                    ForEach(Array(pets.enumerated()), id: \.element.id) { index, p in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPetIndex = index
                            }
                        } label: {
                            Label(pet.name, systemImage: selectedPetIndex == index ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        PRPetAvatar(image: pet.avatarImage, size: 28)
                        
                        Text(pet.name)
                            .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
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
                        .font(PawRoutineTheme.PRFont.title3(.semibold))
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
                        .font(PawRoutineTheme.PRFont.caption(.bold))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(PawRoutineTheme.Colors.bgSecondary, in: Circle())
                }
                
                Text(selectedMonth, format: .dateTime.year().month())
                    .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                    .frame(width: 80)
                
                Button {
                    withAnimation {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(PawRoutineTheme.PRFont.caption(.bold))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(PawRoutineTheme.Colors.bgSecondary, in: Circle())
                }
            }
        }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: Pet.self, inMemory: true)
}

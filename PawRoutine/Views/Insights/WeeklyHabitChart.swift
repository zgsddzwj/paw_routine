//
//  WeeklyHabitChart.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import Charts

struct WeeklyHabitChart: View {
    let pet: Pet
    
    /// 获取本周每天的记录统计
    private var weekData: [DayStat] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        return (0..<7).compactMap { dayOffset -> DayStat? in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { return nil }
            
            let dayRecords = pet.dailyRecords.filter { record in
                calendar.isDate(record.timestamp, inSameDayAs: date)
            }
            
            let weekdaySymbol = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            return DayStat(
                dayName: String(weekdaySymbol.prefix(1)), // 取首字：周一 → "一"
                fullName: weekdaySymbol,
                date: date,
                feedingCount: dayRecords.filter { $0.recordType == .feeding }.count,
                walkingCount: dayRecords.filter { $0.recordType == .walking }.count,
                bathroomCount: dayRecords.filter { $0.recordType == .bathroom }.count,
                medicationCount: dayRecords.filter { $0.recordType == .medication }.count,
                isToday: calendar.isDateInToday(date)
            )
        }
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("本周习惯", systemImage: "chart.bar.xaxis")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("过去7天")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                
                // 柱状图
                Chart(weekData) { stat in
                    BarMark(
                        x: .value("日期", stat.dayName),
                        y: .value("记录数", stat.totalCount),
                        width: .fixed(20)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PawRoutineTheme.Colors.primary.opacity(0.6), PawRoutineTheme.Colors.secondary],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .opacity(stat.isToday ? 1.0 : 0.7)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel("\(value.as(Int.self) ?? 0)")
                            .font(.caption2)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel(centered: true)
                            .font(.caption2)
                    }
                }
                
                // 分类统计
                habitSummary
            }
        }
    }
    
    // MARK: - Habit Summary (分类小计)
    
    private var habitSummary: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
            summaryItem(icon: "fork.knife", label: "喂食", color: PawRoutineTheme.Colors.feeding,
                        count: weekData.reduce(0) { $0 + $1.feedingCount })
            summaryItem(icon: "figure.walk", label: "遛狗", color: PawRoutineTheme.Colors.walking,
                        count: weekData.reduce(0) { $0 + $1.walkingCount })
            summaryItem(icon: "drop.fill", label: "排便", color: PawRoutineTheme.Colors.bathroom,
                        count: weekData.reduce(0) { $0 + $1.bathroomCount })
            summaryItem(icon: "pills.fill", label: "喂药", color: PawRoutineTheme.Colors.medication,
                        count: weekData.reduce(0) { $0 + $1.medicationCount })
        }
    }
    
    private func summaryItem(icon: String, label: String, color: Color, count: Int) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
            
            Text("\(count)")
                .font(.title3.weight(.bold))
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .background(color.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Data Model

struct DayStat: Identifiable {
    let id = UUID()
    let dayName: String
    let fullName: String
    let date: Date
    let feedingCount: Int
    let walkingCount: Int
    let bathroomCount: Int
    let medicationCount: Int
    let isToday: Bool
    
    var totalCount: Int {
        feedingCount + walkingCount + bathroomCount + medicationCount
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            ScrollView {
                WeeklyHabitChart(pet: Pet(name: "测试"))
                    .padding()
            }
        }
    }
    
    return PreviewWrapper()
}

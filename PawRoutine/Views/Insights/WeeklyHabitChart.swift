//
//  WeeklyHabitChart.swift
//  PawRoutine
//
//  本周习惯分析 - 设计稿还原
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
                dayName: String(weekdaySymbol.prefix(1)),
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
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
                // 标题行
                PRSectionHeader("本周习惯分析") { trailing in
                    Text("7月8日 - 7月14日")
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
                
                // 耗时统计
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .foregroundStyle(PawRoutineTheme.Colors.feeding)
                    
                    Text("累计耗时")
                        .font(PawRoutineTheme.PRFont.caption2())
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    Text("4 小时 30 分钟")
                        .font(PawRoutineTheme.PRFont.caption2(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    
                    Spacer()
                }
                
                // 柱状图
                Chart(weekData) { stat in
                    BarMark(
                        x: .value("日期", stat.dayName),
                        y: .value("记录数", stat.totalCount),
                        width: .fixed(22)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                PawRoutineTheme.Colors.walking.opacity(0.6),
                                PawRoutineTheme.Colors.walking
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .opacity(stat.isToday ? 1.0 : 0.65)
                    .cornerRadius(4)
                }
                .frame(height: 160)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel("\(value.as(Int.self) ?? 0)")
                            .font(PawRoutineTheme.PRFont.micro())
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel(centered: true)
                            .font(PawRoutineTheme.PRFont.micro())
                    }
                }
                
                // 分类统计 + 编辑按钮
                HStack(alignment: .center) {
                    Text("喂养次数数据")
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(weekData.reduce(0) { $0 + $1.totalCount }) 次")
                        .font(PawRoutineTheme.PRFont.caption(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.accent)
                    
                    Button("编辑") {
                        // TODO
                    }
                    .font(PawRoutineTheme.PRFont.caption(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
                
                // 分类图标栏
                habitSummary
            }
        }
    }
    
    // MARK: - Habit Summary
    
    private var habitSummary: some View {
        HStack(spacing: 0) {
            summaryItem(icon: "sun.max.fill", label: "今日", color: PawRoutineTheme.Colors.primary)
            Divider()
            summaryItem(icon: "fork.knife", label: "喂食", color: PawRoutineTheme.Colors.feeding)
            Divider()
            summaryItem(icon: "figure.walk", label: "遛狗", color: PawRoutineTheme.Colors.walking)
            Divider()
            summaryItem(icon: "drop.fill", label: "排便", color: PawRoutineTheme.Colors.bathroom)
            Divider()
            summaryItem(icon: "pills.fill", label: "喂药", color: PawRoutineTheme.Colors.medication)
            
            Spacer()
            
            Button {
                // TODO
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
            }
        }
        .padding(.vertical, 10)
        .background(PawRoutineTheme.Colors.bgSecondary, in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
    }
    
    private func summaryItem(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            
            Text(label)
                .font(PawRoutineTheme.PRFont.micro())
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
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

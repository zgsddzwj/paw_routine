//
//  CalendarMonthView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI

struct CalendarMonthView: View {
    let pet: Pet
    @Binding var selectedMonth: Date
    
    private var calendar: Calendar { Calendar.current }
    
    /// 获取当月的天数和记录分布
    private var monthDays: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth) else {
            return []
        }
        
        return range.compactMap { day -> Date? in
            calendar.date(bySetting: .day, value: day, of: selectedMonth)
        }
    }
    
    /// 获取某天是否有记录
    private func hasRecords(on date: Date) -> Bool {
        pet.dailyRecords.contains { record in
            calendar.isDate(record.timestamp, inSameDayAs: date)
        }
    }
    
    /// 获取某天的记录数量（用于显示密度）
    private func recordCount(on date: Date) -> Int {
        pet.dailyRecords.filter { record in
            calendar.isDate(record.timestamp, inSameDayAs: date)
        }.count
    }
    
    /// 获取月份的第一天是星期几
    private var firstWeekday: Int {
        calendar.component(.weekday, from: monthDays.first ?? Date())
    }
    
    /// 星期标题
    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                // 星期标题行
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        Text(weekdaySymbols[index])
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 日历网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    // 前置空白占位
                    ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.clear)
                            .frame(height: 36)
                    }
                    
                    // 当月日期
                    ForEach(monthDays, id: \.self) { date in
                        CalendarDayCell(
                            day: calendar.component(.day, from: date),
                            hasRecords: hasRecords(on: date),
                            recordCount: recordCount(on: date),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
                        )
                    }
                }
                
                // 图例
                HStack(spacing: 16) {
                    legendItem(color: PawRoutineTheme.Colors.walking.opacity(0.3), label: "少")
                    legendItem(color: PawRoutineTheme.Colors.walking.opacity(0.5), label: "中")
                    legendItem(color: PawRoutineTheme.Colors.walking.opacity(0.8), label: "多")
                    
                    Spacer()
                    
                    Text("本月 \(pet.dailyRecords.filter({ calendar.isDate($0.timestamp, equalTo: selectedMonth, toGranularity: .month) }).count) 条记录")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let day: Int
    let hasRecords: Bool
    let recordCount: Int
    let isToday: Bool
    let isCurrentMonth: Bool
    
    private var dotColor: Color {
        if recordCount >= 5 {
            return PawRoutineTheme.Colors.primary.opacity(0.9)
        } else if recordCount >= 3 {
            return PawRoutineTheme.Colors.primary.opacity(0.6)
        } else if recordCount > 0 {
            return PawRoutineTheme.Colors.primary.opacity(0.3)
        }
        return .clear
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(day)")
                .font(.subheadline.weight(isToday ? .bold : .regular))
                .foregroundStyle(
                    isToday ? .white :
                    isCurrentMonth ? .primary : Color(.gray.opacity(0.3))
                )
            
            if hasRecords {
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 36)
        .background(
            Group {
                if isToday {
                    Capsule().fill(PawRoutineTheme.Colors.primary)
                } else {
                    Color.clear
                }
            }
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var date = Date()
        
        var body: some View {
            CalendarMonthView(pet: Pet(name: "测试"), selectedMonth: $date)
                .padding()
        }
    }
    
    return PreviewWrapper()
}

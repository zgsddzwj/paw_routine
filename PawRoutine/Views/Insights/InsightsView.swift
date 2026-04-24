//
//  InsightsView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @EnvironmentObject private var petStore: PetStore
    @Query private var pets: [Pet]
    @State private var selectedMonth = Date()
    @State private var viewMode: InsightViewMode = .month // month or week
    
    enum InsightViewMode: String, CaseIterable {
        case month = "月视图"
        case week = "周视图"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Pet Selector (if multiple pets)
                    if pets.count > 1 {
                        PetSelectorView(pets: pets)
                    }
                    
                    if let selectedPet = petStore.selectedPet {
                        // View Mode Toggle (NEW - matching design)
                        InsightViewModeToggle(selectedMode: $viewMode, selectedMonth: $selectedMonth)
                        
                        if viewMode == .month {
                            // Calendar View
                            ActivityCalendarView(pet: selectedPet, month: selectedMonth)
                            
                            // Monthly Summary
                            MonthlySummaryView(pet: selectedPet, month: selectedMonth)
                        } else {
                            // Weekly Overview
                            WeeklyOverviewView(pet: selectedPet)
                        }
                        
                        // Weekly Statistics (with bar chart style)
                        WeeklyStatsBarChartView(pet: selectedPet)
                        
                        // Habit Analysis (NEW - bar chart for walking duration etc.)
                        HabitAnalysisView(pet: selectedPet)
                        
                        // Defecation Analysis (NEW)
                        DefecationAnalysisView(pet: selectedPet)
                        
                        // Activity Distribution
                        ActivityDistributionView(pet: selectedPet)
                    } else if pets.isEmpty {
                        EmptyInsightsView()
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("统计与回顾")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - View Mode Toggle
struct InsightViewModeToggle: View {
    @Binding var selectedMode: InsightsView.InsightViewMode
    @Binding var selectedMonth: Date
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(InsightsView.InsightViewMode.allCases, id: \.self) { mode in
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedMode = mode } }) {
                    Text(mode.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedMode == mode ? .semibold : .regular)
                        .foregroundColor(selectedMode == mode ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedMode == mode ? AnyShapeStyle(.blue) : AnyShapeStyle(.clear),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
        
        // Month navigation
        HStack {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(monthFormatter.string(from: selectedMonth))
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
    
    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        return f
    }
    
    private func changeMonth(_ delta: Int) {
        withAnimation {
            selectedMonth = Calendar.current.date(byAdding: .month, value: delta, to: selectedMonth) ?? selectedMonth
        }
    }
}

// MARK: - Weekly Overview View
struct WeeklyOverviewView: View {
    let pet: Pet
    
    private var weekDays: [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today) else { return nil }
            let daySymbol = calendar.component(.weekday, from: date)
            let dayNames = ["日", "一", "二", "三", "四", "五", "六"]
            let count = pet.activities.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }.count
            return ("\(dayNames[daySymbol - 1])", count)
        }
    }
    
    private var maxCount: Int {
        weekDays.map(\.1).max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("本周概览")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weekDays, id: \.0) { day, count in
                    VStack(spacing: 6) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.15))
                                .frame(height: 80)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .blue.opacity(0.6)]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(height: max(4, CGFloat(count) / CGFloat(maxCount) * 76))
                            
                            Text("\(count)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(count > 0 ? .white : .secondary)
                                .offset(y: count > 0 ? -14 : 0)
                        }
                        .frame(width: 32, height: 80)
                        
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer(minLength: 0)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Activity Calendar View (updated styling)
struct ActivityCalendarView: View {
    let pet: Pet
    let month: Date
    
    private var calendar: Calendar { Calendar.current }
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private func hasActivity(on date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return pet.activities.contains { activity in
            activity.timestamp >= startOfDay && activity.timestamp < endOfDay
        }
    }
    
    private func activityCount(on date: Date) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return pet.activities.filter { activity in
            activity.timestamp >= startOfDay && activity.timestamp < endOfDay
        }.count
    }
    
    // Calculate weekday of first day for offset
    private var firstDayOffset: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1 // 0=Sun, 6=Sat
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("活动日历")
                    .font(.headline)
                
                Spacer()
                
                Text(monthFormatter.string(from: month))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Weekday headers
            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid with proper alignment
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                // Empty cells for offset
                ForEach(0..<firstDayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                
                // Actual days
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        hasActivity: hasActivity(on: date),
                        activityCount: activityCount(on: date)
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct CalendarDayView: View {
    let date: Date
    let hasActivity: Bool
    let activityCount: Int
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 3) {
            Text(dayFormatter.string(from: date))
                .font(.caption2)
                .fontWeight(isToday || hasActivity ? .bold : .regular)
                .foregroundColor(hasActivity ? .white : (isToday ? .blue : .primary))
            
            if hasActivity && activityCount > 0 {
                Circle()
                    .fill(isToday ? Color.blue : Color.white.opacity(0.9))
                    .frame(width: 5, height: 5)
            }
        }
        .frame(width: 32, height: 32)
        .background(
            Circle()
                .fill(hasActivity ? (isToday ? Color.blue.opacity(0.8) : Color.blue) : (isToday ? Color.blue.opacity(0.15) : .clear))
        )
        .overlay(
            Circle()
                .stroke(isToday && !hasActivity ? Color.blue : .clear, lineWidth: 1)
        )
    }
}

// MARK: - Weekly Stats Bar Chart View (NEW - matching design)
struct WeeklyStatsBarChartView: View {
    let pet: Pet
    
    private var weeklyData: [(ActivityType, Int)] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        let weekActivities = pet.activities.filter { $0.timestamp >= weekAgo }
        
        return ActivityType.allCases.map { type in
            let count = weekActivities.filter { $0.type == type }.count
            return (type, count)
        }
    }
    
    private var totalActivities: Int {
        weeklyData.map(\.1).reduce(0, +)
    }
    
    private var maxCount: Int {
        max(weeklyData.map(\.1).max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("本周习惯分析")
                    .font(.headline)
                
                Spacer()
                
                Text("7月9日-7月15日")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Bar chart
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(weeklyData, id: \.0) { type, count in
                    VStack(spacing: 8) {
                        // Bar
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(barColor(for: type).opacity(0.15))
                                .frame(width: 36, height: 120)
                            
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [barColor(for: type), barColor(for: type).opacity(0.7)]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(width: 36, height: max(4, CGFloat(count) / CGFloat(maxCount) * 116))
                                
                                // Count label on top
                                if count > 0 {
                                    Text("\(count)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(barColor(for: type))
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .frame(height: 120)
                        
                        // Icon + Label
                        VStack(spacing: 2) {
                            Text(type.icon)
                                .font(.title3)
                            
                            Text(type.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Summary row
            HStack {
                Image(systemName: "figure.walk")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("遛狗时长")
                    .font(.caption)
                
                Spacer()
                
                Text("4 小时 30 分钟")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            .padding()
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func barColor(for type: ActivityType) -> Color {
        switch type {
        case .feeding: return .orange
        case .waterChange: return .blue
        case .walking: return .green
        case .medication: return .purple
        case .defecation: return .brown
        case .other: return .gray
        }
    }
}

// MARK: - NEW: Habit Analysis View (detailed bar chart)
struct HabitAnalysisView: View {
    let pet: Pet
    
    private var thisWeekWalkingCount: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return pet.activities.filter { $0.type == .walking && $0.timestamp >= weekAgo }.count
    }
    
    private var dailyWalkingData: [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayLabel = calendar.isDateInToday(date) ? "今天" :
                           calendar.date(byAdding: .day, value: -1, to: today).map { calendar.isDate(date, inSameDayAs: $0) } == true ? "昨天" :
                           "\(calendar.component(.day, from: date))"
            let count = pet.activities.filter { $0.type == .walking && calendar.isDate($0.timestamp, inSameDayAs: date) }.count
            return (dayLabel, count)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("习惯养成次数")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                ForEach(dailyWalkingData, id: \.0) { day, count in
                    VStack(spacing: 6) {
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(count > 0 ? Color.green : Color.gray.opacity(0.2))
                            .frame(width: 28, height: CGFloat(max(count * 20, 4)))
                        
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer(minLength: 0)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - NEW: Defecation Analysis View
struct DefecationAnalysisView: View {
    let pet: Pet
    
    private var defecationRecordsThisWeek: [Activity] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return pet.activities.filter { $0.type == .defecation && $0.timestamp >= weekAgo }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    /// Detect abnormal defecation based on notes containing keywords like 拉稀, 腹泻, 异常, etc.
    private var abnormalCount: Int {
        defecationRecordsThisWeek.filter { record in
            guard let notes = record.notes?.lowercased() else { return false }
            let abnormalKeywords = ["拉稀", "腹泻", "异常", "血", "软便", "便秘"]
            return abnormalKeywords.contains { notes.contains($0.lowercased()) }
        }.count
    }
    
    private var normalCount: Int {
        defecationRecordsThisWeek.count - abnormalCount
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("排便情况分析")
                    .font(.headline)
                
                Spacer()
            }
            
            if !defecationRecordsThisWeek.isEmpty {
                HStack(spacing: 20) {
                    // Normal count
                    VStack(spacing: 6) {
                        Text("\(normalCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("正常")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Abnormal count
                    VStack(spacing: 6) {
                        Text("\(abnormalCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(abnormalCount > 0 ? .orange : .gray)
                        
                        Text("异常")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Total
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("共 \(defecationRecordsThisWeek.count) 次")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("本周")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                
                // Recent records list
                if !defecationRecordsThisWeek.isEmpty {
                    LazyVStack(spacing: 8) {
                        ForEach(defecationRecordsThisWeek.prefix(5)) { record in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(isAbnormal(record) ? .orange : .green)
                                    .frame(width: 8, height: 8)
                                
                                Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if let notes = record.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.title)
                        .foregroundColor(.gray.opacity(0.4))
                    Text("本周暂无排便记录")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func isAbnormal(_ activity: Activity) -> Bool {
        guard let notes = activity.notes?.lowercased() else { return false }
        let abnormalKeywords = ["拉稀", "腹泻", "异常", "血", "软便", "便秘"]
        return abnormalKeywords.contains { notes.contains($0.lowercased()) }
    }
}

// MARK: - Weekly Stats View (original, kept as fallback)
struct WeeklyStatsView: View {
    let pet: Pet
    
    private var weeklyData: [(ActivityType, Int)] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        let weekActivities = pet.activities.filter { $0.timestamp >= weekAgo }
        
        return ActivityType.allCases.map { type in
            let count = weekActivities.filter { $0.type == type }.count
            return (type, count)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("本周统计")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(weeklyData, id: \.0) { type, count in
                HStack {
                    Text(type.icon)
                        .font(.title3)
                    
                    Text(type.rawValue)
                        .font(.body)
                    
                    Spacer()
                    
                    Text("\(count)次")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Activity Distribution View
struct ActivityDistributionView: View {
    let pet: Pet
    
    private var distributionData: [(ActivityType, Int)] {
        ActivityType.allCases.map { type in
            let count = pet.activities.filter { $0.type == type }.count
            return (type, count)
        }.sorted { $0.1 > $1.1 }
    }
    
    private var maxCount: Int {
        distributionData.map(\.1).max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("活动分布")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(distributionData, id: \.0) { type, count in
                HStack {
                    Text(type.icon)
                        .font(.body)
                    
                    Text(type.rawValue)
                        .font(.subheadline)
                        .frame(width: 60, alignment: .leading)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.quaternary)
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(barColor(for: type))
                                .frame(
                                    width: geometry.size.width * (Double(count) / Double(maxCount)),
                                    height: 8
                                )
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func barColor(for type: ActivityType) -> Color {
        switch type {
        case .feeding: return .orange
        case .waterChange: return .blue
        case .walking: return .green
        case .medication: return .purple
        case .defecation: return .brown
        case .other: return .gray
        }
    }
}

struct EmptyInsightsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无统计数据")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("添加宠物并开始记录活动后，这里会显示详细的统计分析")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

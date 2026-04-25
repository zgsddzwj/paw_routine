//
//  InsightsView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @EnvironmentObject private var petStore: PetStore
    @Query private var pets: [Pet]
    @Query private var settings: [AppSettings]
    @State private var selectedMonth = Date()
    @State private var viewMode: InsightViewMode = .calendar
    @State private var showingProSheet = false
    
    enum InsightViewMode: String, CaseIterable {
        case calendar = "Calendar"
        case week = "Week"
        case month = "Month"
        
        var displayName: String {
            NSLocalizedString(rawValue, comment: "Insight view mode")
        }
    }
    
    private var currentSettings: AppSettings {
        settings.first ?? AppSettings()
    }
    
    private var isPro: Bool {
        IAPManager.shared.isPro || currentSettings.isPro
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawRoutineTheme.Spacing.xl) {
                        if pets.count > 1 {
                            PetSelectorView(pets: pets)
                        }
                        
                        if let selectedPet = petStore.selectedPet {
                            InsightViewModeToggle(
                                selectedMode: $viewMode,
                                selectedMonth: $selectedMonth,
                                isPro: isPro,
                                onProRequired: { showingProSheet = true }
                            )
                            
                            switch viewMode {
                            case .calendar:
                                ActivityCalendarView(pet: selectedPet, month: selectedMonth)
                                WeeklyStatsBarChartView(pet: selectedPet)
                                ActivityDistributionView(pet: selectedPet)
                            case .week:
                                WeeklyOverviewView(pet: selectedPet)
                                WeeklyStatsBarChartView(pet: selectedPet)
                                HabitAnalysisView(pet: selectedPet)
                                DefecationAnalysisView(pet: selectedPet)
                            case .month:
                                if isPro {
                                    MonthlySummaryView(pet: selectedPet, month: selectedMonth)
                                    ActivityDistributionView(pet: selectedPet)
                                } else {
                                    ProRequiredCard(onTap: { showingProSheet = true })
                                    ActivityDistributionView(pet: selectedPet)
                                }
                            }
                        } else if pets.isEmpty {
                            EmptyInsightsView()
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.sm)
                }
            }
            .navigationTitle("Statistics & Review")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingProSheet) {
                ProUpgradeView(settings: currentSettings)
            }
        }
    }
}

// MARK: - View Mode Toggle

struct InsightViewModeToggle: View {
    @Binding var selectedMode: InsightsView.InsightViewMode
    @Binding var selectedMonth: Date
    var isPro: Bool
    var onProRequired: () -> Void
    
    var body: some View {
        VStack(spacing: PawRoutineTheme.Spacing.md) {
            HStack(spacing: 4) {
                ForEach(InsightsView.InsightViewMode.allCases, id: \.self) { mode in
                    let isLocked = mode == .month && !isPro
                    Button(action: {
                        if isLocked {
                            onProRequired()
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMode = mode
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9))
                            }
                            Text(mode.displayName)
                                .font(PawRoutineTheme.PRFont.caption(.semibold))
                        }
                        .foregroundColor(selectedMode == mode ? .white : (isLocked ? PawRoutineTheme.Colors.textTertiary : PawRoutineTheme.Colors.textSecondary))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedMode == mode
                            ? AnyShapeStyle(PawRoutineTheme.Colors.primary)
                            : AnyShapeStyle(Color.clear),
                            in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.sm, style: .continuous)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(4)
            .background(PawRoutineTheme.Colors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md, style: .continuous))
            .shadow(
                color: PawRoutineTheme.Shadows.small.color,
                radius: PawRoutineTheme.Shadows.small.radius,
                x: PawRoutineTheme.Shadows.small.x,
                y: PawRoutineTheme.Shadows.small.y
            )
            
            if selectedMode != .week {
                HStack {
                    Button(action: { changeMonth(-1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                            .frame(width: 32, height: 32)
                            .background(PawRoutineTheme.Colors.bgCard)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(monthFormatter.string(from: selectedMonth))
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                            .frame(width: 32, height: 32)
                            .background(PawRoutineTheme.Colors.bgCard)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = NSLocalizedString("yyyy年M月", comment: "")
        return f
    }
    
    private func changeMonth(_ delta: Int) {
        withAnimation {
            selectedMonth = Calendar.current.date(byAdding: .month, value: delta, to: selectedMonth) ?? selectedMonth
        }
    }
}

// MARK: - Weekly Overview

struct WeeklyOverviewView: View {
    let pet: Pet
    
    private var weekDays: [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today) else { return nil }
            let daySymbol = calendar.component(.weekday, from: date)
            let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let count = pet.activities.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }.count
            return (dayNames[daySymbol - 1], count)
        }
    }
    
    private var maxCount: Int {
        max(weekDays.map(\.1).max() ?? 1, 1)
    }
    
    var body: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                Text("Weekly Overview")
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(weekDays, id: \.0) { day, count in
                        VStack(spacing: 6) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(PawRoutineTheme.Colors.primary.opacity(0.1))
                                    .frame(height: 100)
                                
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(PawRoutineTheme.Colors.primary)
                                    .frame(height: max(4, CGFloat(count) / CGFloat(maxCount) * 96))
                            }
                            .frame(width: 36, height: 100)
                            
                            Text(day)
                                .font(PawRoutineTheme.PRFont.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

// MARK: - Activity Calendar

struct ActivityCalendarView: View {
    let pet: Pet
    let month: Date
    
    private var calendar: Calendar { Calendar.current }
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = NSLocalizedString("yyyy年M月", comment: "")
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
        return pet.activities.contains { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
    }
    
    private func activityCount(on date: Date) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        return pet.activities.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.count
    }
    
    private var firstDayOffset: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    var body: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                HStack {
                    Text("Activity Calendar")
                        .font(PawRoutineTheme.PRFont.title3(.bold))
                    
                    Spacer()
                    
                    Text(monthFormatter.string(from: month))
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
                
                HStack {
                    let weekDaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    ForEach(weekDaySymbols.indices, id: \.self) { i in
                        Text(LocalizedStringKey(weekDaySymbols[i]))
                            .font(PawRoutineTheme.PRFont.caption2(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(0..<firstDayOffset, id: \.self) { _ in
                        Color.clear.frame(width: 36, height: 36)
                    }
                    
                    ForEach(daysInMonth, id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            hasActivity: hasActivity(on: date),
                            activityCount: activityCount(on: date)
                        )
                    }
                }
            }
        }
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
        VStack(spacing: 2) {
            Text(dayFormatter.string(from: date))
                .font(PawRoutineTheme.PRFont.caption2(.bold))
                .foregroundColor(isToday ? .white : (hasActivity ? .white : PawRoutineTheme.Colors.textPrimary))
            
            if hasActivity && activityCount > 0 {
                Circle()
                    .fill(isToday ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(width: 36, height: 36)
        .background(
            Circle()
                .fill(hasActivity
                      ? (isToday ? PawRoutineTheme.Colors.primary.opacity(0.85) : PawRoutineTheme.Colors.primary)
                      : (isToday ? PawRoutineTheme.Colors.primary.opacity(0.15) : Color.clear))
        )
        .overlay(
            Circle()
                .stroke(isToday && !hasActivity ? PawRoutineTheme.Colors.primary : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - Weekly Stats Bar Chart

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
    
    private var maxCount: Int {
        max(weeklyData.map(\.1).max() ?? 1, 1)
    }
    
    var body: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                HStack {
                    Text("Weekly Habit Analysis")
                        .font(PawRoutineTheme.PRFont.title3(.bold))
                    
                    Spacer()
                }
                
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(weeklyData.filter { $0.1 > 0 }, id: \.0) { type, count in
                        VStack(spacing: 6) {
                            Text("\(count)")
                                .font(PawRoutineTheme.PRFont.caption2(.bold))
                                .foregroundStyle(barColor(for: type))
                            
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(barColor(for: type).opacity(0.12))
                                    .frame(width: 32, height: 100)
                                
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(barColor(for: type))
                                    .frame(width: 32, height: max(4, CGFloat(count) / CGFloat(maxCount) * 96))
                            }
                            .frame(height: 100)
                            
                            Text(type.displayName)
                                .font(PawRoutineTheme.PRFont.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
            }
        }
    }
    
    private func barColor(for type: ActivityType) -> Color {
        switch type {
        case .feeding: return PawRoutineTheme.Colors.feeding
        case .waterChange: return PawRoutineTheme.Colors.water
        case .walking: return PawRoutineTheme.Colors.walking
        case .medication: return .purple
        case .defecation: return PawRoutineTheme.Colors.bathroom
        case .other: return .gray
        }
    }
}

// MARK: - Habit Analysis

struct HabitAnalysisView: View {
    let pet: Pet
    
    private var dailyWalkingData: [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayLabel: String
            if calendar.isDateInToday(date) {
                dayLabel = NSLocalizedString("Today", comment: "")
            } else if calendar.isDateInYesterday(date) {
                dayLabel = NSLocalizedString("Yesterday", comment: "")
            } else {
                dayLabel = String(format: NSLocalizedString("%d日", comment: ""), calendar.component(.day, from: date))
            }
            let count = pet.activities.filter { $0.type == .walking && calendar.isDate($0.timestamp, inSameDayAs: date) }.count
            return (dayLabel, count)
        }
    }
    
    var body: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                Text("Habit Count")
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    ForEach(dailyWalkingData, id: \.0) { day, count in
                        VStack(spacing: 6) {
                            Text("\(count)")
                                .font(PawRoutineTheme.PRFont.caption2(.bold))
                                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                            
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(count > 0 ? PawRoutineTheme.Colors.walking : PawRoutineTheme.Colors.separator)
                                .frame(width: 28, height: CGFloat(max(count * 16, 4)))
                            
                            Text(day)
                                .font(PawRoutineTheme.PRFont.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

// MARK: - Defecation Analysis

struct DefecationAnalysisView: View {
    let pet: Pet
    
    private var defecationRecordsThisWeek: [Activity] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return pet.activities.filter { $0.type == .defecation && $0.timestamp >= weekAgo }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
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
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                Text("Defecation Analysis")
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !defecationRecordsThisWeek.isEmpty {
                    HStack(spacing: 20) {
                        StatBadge(
                            value: "\(normalCount)",
                            label: "Normal",
                            color: PawRoutineTheme.Colors.walking
                        )
                        
                        StatBadge(
                            value: "\(abnormalCount)",
                            label: "Abnormal",
                            color: abnormalCount > 0 ? PawRoutineTheme.Colors.feeding : PawRoutineTheme.Colors.textTertiary
                        )
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: NSLocalizedString("共 %d 次", comment: ""), defecationRecordsThisWeek.count))
                                .font(PawRoutineTheme.PRFont.caption(.medium))
                                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                            Text("This Week")
                                .font(PawRoutineTheme.PRFont.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    .padding()
                    .background(PawRoutineTheme.Colors.bgSecondary.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md, style: .continuous))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.3))
                        Text("No defecation records this week")
                            .font(PawRoutineTheme.PRFont.bodyText())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
    }
}

struct StatBadge: View {
    let value: LocalizedStringKey
    let label: LocalizedStringKey
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(PawRoutineTheme.PRFont.title2(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(PawRoutineTheme.PRFont.caption())
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
        }
    }
}

// MARK: - Activity Distribution

struct ActivityDistributionView: View {
    let pet: Pet
    
    private var distributionData: [(ActivityType, Int)] {
        ActivityType.allCases.map { type in
            let count = pet.activities.filter { $0.type == type }.count
            return (type, count)
        }.sorted { $0.1 > $1.1 }
    }
    
    private var maxCount: Int {
        max(distributionData.map(\.1).max() ?? 1, 1)
    }
    
    var body: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                Text("Activity Distribution")
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    ForEach(distributionData.filter { $0.1 > 0 }, id: \.0) { type, count in
                        HStack(spacing: 10) {
                            ActivityTypeIcon(type: type, size: 16)
                            
                            Text(type.displayName)
                                .font(PawRoutineTheme.PRFont.caption(.medium))
                                .frame(width: 50, alignment: .leading)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(PawRoutineTheme.Colors.bgSecondary)
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(barColor(for: type))
                                        .frame(
                                            width: geometry.size.width * (Double(count) / Double(maxCount)),
                                            height: 8
                                        )
                                }
                            }
                            .frame(height: 8)
                            
                            Text("\(count)")
                                .font(PawRoutineTheme.PRFont.caption(.bold))
                                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
    
    private func barColor(for type: ActivityType) -> Color {
        switch type {
        case .feeding: return PawRoutineTheme.Colors.feeding
        case .waterChange: return PawRoutineTheme.Colors.water
        case .walking: return PawRoutineTheme.Colors.walking
        case .medication: return .purple
        case .defecation: return PawRoutineTheme.Colors.bathroom
        case .other: return .gray
        }
    }
}

// MARK: - Pro Required Card

struct ProRequiredCard: View {
    let onTap: () -> Void
    
    var body: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.md) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                    )
                
                Text("Pro Feature")
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text("Monthly summaries, trend analysis, and other advanced stats require FurryNote Pro.")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button(action: onTap) {
                    Text("Unlock Pro")
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md, style: .continuous)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, PawRoutineTheme.Spacing.md)
        }
    }
}

// MARK: - Empty Insights

struct EmptyInsightsView: View {
    var body: some View {
        VStack(spacing: PawRoutineTheme.Spacing.xl) {
            Spacer().frame(height: 60)
            
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.2))
            
            VStack(spacing: PawRoutineTheme.Spacing.sm) {
                Text("No statistics yet")
                    .font(PawRoutineTheme.PRFont.title2(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text("Add a pet and start recording activities to see detailed statistics here.")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PawRoutineTheme.Spacing.xxl)
            }
            
            Spacer()
        }
    }
}

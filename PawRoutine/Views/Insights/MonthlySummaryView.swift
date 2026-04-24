//
//  MonthlySummaryView.swift
//  PawRoutine
//
//  月度汇总 - 从 PawRoutine2 集成，适配当前 Activity 模型
//

import SwiftUI

struct MonthlySummaryView: View {
    let pet: Pet
    let month: Date
    
    private var calendar: Calendar { Calendar.current }
    
    /// 当月记录
    private var monthRecords: [Activity] {
        pet.activities.filter { record in
            calendar.isDate(record.timestamp, equalTo: month, toGranularity: .month)
        }
    }
    
    // MARK: - 统计数据
    
    private var totalRecords: Int { monthRecords.count }
    
    private var feedingCount: Int {
        monthRecords.filter { $0.type == .feeding }.count
    }
    
    private var walkingCount: Int {
        monthRecords.filter { $0.type == .walking }.count
    }
    
    private var activeDays: Int {
        Set(monthRecords.map { calendar.startOfDay(for: $0.timestamp) }).count
    }
    
    /// 当月天数
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: month)?.count ?? 30
    }
    
    /// 活跃率
    private var activityRate: Double {
        guard daysInMonth > 0 else { return 0 }
        let today = Date()
        let isCurrentMonth = calendar.isDate(month, equalTo: today, toGranularity: .month)
        let maxDays = isCurrentMonth ? calendar.component(.day, from: today) : daysInMonth
        return min(Double(activeDays) / Double(maxDays), 1.0)
    }
    
    var body: some View {
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
                PRSectionHeader("月度汇总")
                
                // 活跃度环形进度 + 统计数字
                HStack(spacing: PawRoutineTheme.Spacing.xl) {
                    ZStack {
                        Circle()
                            .stroke(PawRoutineTheme.Colors.separator, lineWidth: 10)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: activityRate)
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        PawRoutineTheme.Colors.primary.opacity(0.6),
                                        PawRoutineTheme.Colors.secondary
                                    ],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.0), value: activityRate)
                        
                        VStack(spacing: 2) {
                            Text("\(Int(activityRate * 100))%")
                                .font(PawRoutineTheme.PRFont.title3(.bold))
                            Text("活跃度")
                                .font(PawRoutineTheme.PRFont.micro())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        summaryRow(label: "总记录", value: "\(totalRecords)", icon: "list.bullet.rectangle.fill")
                        summaryRow(label: "活跃天数", value: "\(activeDays)/\(min(daysInMonth, calendar.component(.day, from: Date())))", icon: "calendar.badge.checkmark")
                        summaryRow(label: "喂食次数", value: "\(feedingCount)", icon: "fork.knife")
                        summaryRow(label: "遛狗次数", value: "\(walkingCount)", icon: "figure.walk")
                    }
                }
                
                // 成就提示
                if totalRecords > 50 {
                    achievementBadge(text: "🏆 超级铲屎官！本月已记录 \(totalRecords) 条")
                } else if totalRecords > 20 {
                    achievementBadge(text: "⭐ 很棒！继续保持！")
                } else if totalRecords > 0 {
                    achievementBadge(text: "💪 每一次记录都是对\(pet.name)的爱")
                }
            }
        }
    }
    
    private func summaryRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.5))
                .frame(width: 16)
            
            Text(label)
                .font(PawRoutineTheme.PRFont.bodyText())
            
            Spacer()
            
            Text(value)
                .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                .monospacedDigit()
        }
    }
    
    private func achievementBadge(text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(PawRoutineTheme.PRFont.bodyText(.medium))
            Spacer()
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    PawRoutineTheme.Colors.accent.opacity(0.08),
                    PawRoutineTheme.Colors.accent.opacity(0.03)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md)
        )
    }
}

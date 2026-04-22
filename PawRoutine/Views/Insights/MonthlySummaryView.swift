//
//  MonthlySummaryView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI

struct MonthlySummaryView: View {
    let pet: Pet
    let month: Date
    
    private var calendar: Calendar { Calendar.current }
    
    /// 当月记录
    private var monthRecords: [DailyRecord] {
        pet.dailyRecords.filter { record in
            calendar.isDate(record.timestamp, equalTo: month, toGranularity: .month)
        }
    }
    
    // MARK: - 统计数据
    
    private var totalRecords: Int { monthRecords.count }
    
    private var feedingCount: Int {
        monthRecords.filter { $0.recordType == .feeding }.count
    }
    
    private var walkingCount: Int {
        monthRecords.filter { $0.recordType == .walking }.count
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
        return min(Double(activeDays) / Double(min(daysInMonth, calendar.component(.day, from: Date()))), 1.0)
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("月度汇总", systemImage: "sum")
                    .font(.headline)
                
                // 活跃度环形进度
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.1), lineWidth: 10)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: activityRate)
                            .stroke(
                                AngularGradient(
                                    colors: [PawRoutineTheme.Colors.primary.opacity(0.6), PawRoutineTheme.Colors.secondary],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.0), value: activityRate)
                        
                        VStack(spacing: 2) {
                            Text("\(Int(activityRate * 100))%")
                                .font(.title3.weight(.bold))
                            Text("活跃度")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
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
                .foregroundStyle(PawRoutineTheme.Colors.secondary.opacity(0.7))
                .frame(width: 16)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
    }
    
    private func achievementBadge(text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.subheadline.weight(.medium))
            Spacer()
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    PawRoutineTheme.Colors.accent.opacity(0.08),
                    PawRoutineTheme.Colors.accent.opacity(0.04)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            ScrollView {
                MonthlySummaryView(pet: Pet(name: "旺财"), month: Date())
                    .padding()
            }
        }
    }
    
    return PreviewWrapper()
}

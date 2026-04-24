//
//  WeightTrackingView.swift
//  PawRoutine
//
//  体重追踪 - 从 PawRoutine2 回滚
//

import SwiftUI
import SwiftData
import Charts

struct WeightTrackingView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAddWeight = false
    @State private var selectedView: WeightViewType = .chart
    
    enum WeightViewType: String, CaseIterable {
        case chart = "图表"
        case list = "列表"
    }
    
    private var sortedRecords: [WeightRecord] {
        pet.weightRecords.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 图表/列表切换
                viewTypePicker
                
                // 最新体重摘要
                latestWeightSummary
                
                // 图表或列表
                if selectedView == .chart {
                    weightChartCard
                } else {
                    weightListCard
                }
                
                // 历史记录
                historyList
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
        .navigationTitle("体重追踪")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddWeight = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showAddWeight) {
            AddWeightRecordView(pet: pet)
        }
    }
    
    // MARK: - View Type Picker
    
    private var viewTypePicker: some View {
        Picker("视图", selection: $selectedView) {
            ForEach(WeightViewType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, PawRoutineTheme.Spacing.lg)
    }
    
    // MARK: - Latest Weight Summary
    
    private var latestWeightSummary: some View {
        HStack(spacing: PawRoutineTheme.Spacing.lg) {
            if let latest = sortedRecords.last {
                VStack(alignment: .leading, spacing: 4) {
                    Text("最新体重")
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(latest.weight, specifier: "%.1f")")
                            .font(PawRoutineTheme.PRFont.largeTitle(.bold))
                        
                        Text("kg")
                            .font(PawRoutineTheme.PRFont.title3())
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    }
                    
                    Text(latest.date, format: .dateTime.year().month().day())
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
                
                Spacer()
                
                // 对比上次
                if let previous = sortedRecords.dropLast().last {
                    let diff = latest.weight - previous.weight
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("对比上次")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        
                        HStack(spacing: 2) {
                            Text(diff >= 0 ? "+" : "-")
                            Text("\(abs(diff), specifier: "%.1f") kg")
                            Image(systemName: diff >= 0 ? "arrow.up.right" : "arrow.down.right")
                        }
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundStyle(diff >= 0 ? PawRoutineTheme.Colors.secondary : PawRoutineTheme.Colors.medication)
                    }
                }
            } else {
                Text("暂无体重记录")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, PawRoutineTheme.Spacing.lg)
        .padding(.top, PawRoutineTheme.Spacing.sm)
    }
    
    // MARK: - Weight Chart Card
    
    private var weightChartCard: some View {
        PRCard {
            if sortedRecords.count >= 2 {
                Chart(sortedRecords) { record in
                    LineMark(
                        x: .value("日期", record.date),
                        y: .value("体重", record.weight)
                    )
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("日期", record.date),
                        y: .value("体重", record.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PawRoutineTheme.Colors.primary.opacity(0.2), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    PointMark(
                        x: .value("日期", record.date),
                        y: .value("体重", record.weight)
                    )
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                    .symbolSize(40)
                    
                    // 标注最新值
                    if record.id == sortedRecords.last?.id {
                        RuleMark(y: .value("体重", record.weight))
                            .foregroundStyle(Color.clear)
                            .annotation(position: .top) {
                                VStack(spacing: 2) {
                                    Text(record.date, format: .dateTime.year().month().day())
                                        .font(PawRoutineTheme.PRFont.micro())
                                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                    Text("\(record.weight, specifier: "%.1f") kg")
                                        .font(PawRoutineTheme.PRFont.caption(.bold))
                                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                            }
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            Text("\(value.as(Double.self) ?? 0, specifier: "%.0f")")
                                .font(PawRoutineTheme.PRFont.micro())
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month().day())
                                    .font(PawRoutineTheme.PRFont.micro())
                            }
                        }
                    }
                }
            } else {
                Text("至少需要2条记录才能显示图表")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, minHeight: 160)
            }
        }
    }
    
    // MARK: - Weight List Card (简化列表视图)
    
    private var weightListCard: some View {
        PRCard {
            VStack(spacing: 0) {
                ForEach(Array(sortedRecords.reversed().enumerated()), id: \.element.id) { index, record in
                    HStack {
                        Text(record.date, format: .dateTime.year().month().day())
                            .font(PawRoutineTheme.PRFont.bodyText())
                        
                        Spacer()
                        
                        Text("\(record.weight, specifier: "%.1f") kg")
                            .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                            .monospacedDigit()
                    }
                    .padding(.vertical, 10)
                    
                    if index < sortedRecords.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }
    
    // MARK: - History List
    
    private var historyList: some View {
        PRCard(padding: .init(top: 16, leading: 16, bottom: 4, trailing: 16)) {
            VStack(alignment: .leading, spacing: 0) {
                Text("历史记录")
                    .font(PawRoutineTheme.PRFont.title3(.semibold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    .padding(.bottom, PawRoutineTheme.Spacing.md)
                
                if sortedRecords.isEmpty {
                    Text("还没有体重记录")
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else {
                    ForEach(Array(sortedRecords.reversed().enumerated()), id: \.element.id) { index, record in
                        historyRow(record: record, isLast: index == sortedRecords.count - 1)
                    }
                }
            }
        }
    }
    
    private func historyRow(record: WeightRecord, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(record.date, format: .dateTime.year().month().day())
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(record.weight, specifier: "%.1f") kg")
                    .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            .padding(.vertical, 12)
            
            if !isLast {
                Divider()
            }
        }
    }
}

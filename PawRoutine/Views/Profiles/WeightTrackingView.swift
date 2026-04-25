//
//  WeightTrackingView.swift
//  PawRoutine
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
    @State private var showingEditSheet = false
    @State private var selectedRecord: WeightRecord?
    
    enum WeightViewType: String, CaseIterable {
        case chart = "Chart"
        case list = "List"
        
        var displayName: String {
            NSLocalizedString(rawValue, comment: "Weight view type")
        }
    }
    
    private var sortedRecords: [WeightRecord] {
        pet.weightRecords.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: PawRoutineTheme.Spacing.lg) {
                    latestWeightCard
                    viewTypePicker
                    
                    if selectedView == .chart {
                        weightChartCard
                    } else {
                        weightListCard
                    }
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.bottom, PawRoutineTheme.Spacing.xxxl)
            }
        }
        .navigationTitle("Weight Tracking")
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
        .sheet(isPresented: $showingEditSheet) {
            if let record = selectedRecord {
                EditWeightRecordView(record: record, pet: pet)
            }
        }
    }
    
    private var latestWeightCard: some View {
        PRCard(padding: .init(top: 20, leading: 20, bottom: 20, trailing: 20)) {
            HStack(spacing: PawRoutineTheme.Spacing.lg) {
                if let latest = sortedRecords.last {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Latest Weight")
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
                    
                    if let previous = sortedRecords.dropLast().last {
                        let diff = latest.weight - previous.weight
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Compare with Last")
                                .font(PawRoutineTheme.PRFont.caption())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: diff >= 0 ? "arrow.up.forward" : "arrow.down.forward")
                                    .font(.system(size: 12, weight: .bold))
                                Text("\(abs(diff), specifier: "%.1f") kg")
                                    .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                            }
                            .foregroundStyle(diff >= 0 ? PawRoutineTheme.Colors.walking : .red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                (diff >= 0 ? PawRoutineTheme.Colors.walking : .red).opacity(0.1),
                                in: Capsule()
                            )
                        }
                    }
                } else {
                    Text("No weight records")
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
        }
    }
    
    private var viewTypePicker: some View {
        HStack(spacing: 4) {
            ForEach(WeightViewType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedView = type
                    }
                } label: {
                    Text(type.displayName)
                        .font(PawRoutineTheme.PRFont.caption(.semibold))
                        .foregroundColor(selectedView == type ? .white : PawRoutineTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedView == type
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
    }
    
    private var weightChartCard: some View {
        PRCard {
            if sortedRecords.count >= 2 {
                Chart(sortedRecords) { record in
                    LineMark(
                        x: .value("Date", record.date),
                        y: .value("Weight", record.weight)
                    )
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    
                    AreaMark(
                        x: .value("Date", record.date),
                        y: .value("Weight", record.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PawRoutineTheme.Colors.primary.opacity(0.15), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    PointMark(
                        x: .value("Date", record.date),
                        y: .value("Weight", record.weight)
                    )
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                    .symbolSize(50)
                }
                .frame(height: 220)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            Text("\(value.as(Double.self) ?? 0, specifier: "%.0f")")
                                .font(PawRoutineTheme.PRFont.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month().day())
                                    .font(PawRoutineTheme.PRFont.caption2())
                                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36))
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.4))
                    Text(NSLocalizedString("At least 2 records are needed to display the chart", comment: ""))
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity, minHeight: 160)
            }
        }
    }
    
    private var weightListCard: some View {
        PRCard(padding: .init(top: 4, leading: 16, bottom: 4, trailing: 16)) {
            VStack(spacing: 0) {
                ForEach(Array(sortedRecords.reversed().enumerated()), id: \.element.id) { index, record in
                    HStack(spacing: PawRoutineTheme.Spacing.md) {
                        // Left color indicator
                        Circle()
                            .fill(PawRoutineTheme.Colors.primary.opacity(0.2))
                            .frame(width: 8, height: 8)
                        
                        Text(record.date, format: .dateTime.year().month().day())
                            .font(PawRoutineTheme.PRFont.bodyText())
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                        
                        Spacer()
                        
                        Text("\(record.weight, specifier: "%.1f") kg")
                            .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    }
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedRecord = record
                        showingEditSheet = true
                    }
                    .contextMenu {
                        Button {
                            selectedRecord = record
                            showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            deleteRecord(record)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    
                    if index < sortedRecords.count - 1 {
                        Divider().padding(.leading, 24)
                    }
                }
            }
        }
    }
    
    private func deleteRecord(_ record: WeightRecord) {
        if let index = pet.weightRecords.firstIndex(where: { $0.id == record.id }) {
            pet.weightRecords.remove(at: index)
        }
        modelContext.delete(record)
        try? modelContext.save()
    }
}

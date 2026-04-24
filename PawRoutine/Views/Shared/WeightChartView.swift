//
//  WeightChartView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import Charts

struct WeightChartView: View {
    let pet: Pet
    
    private var sortedWeightRecords: [WeightRecord] {
        pet.weightRecords.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Chart
                if sortedWeightRecords.count >= 2 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("体重趋势")
                            .font(.headline)
                        
                        Chart(sortedWeightRecords) { record in
                            LineMark(
                                x: .value("日期", record.date),
                                y: .value("体重", record.weight)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            PointMark(
                                x: .value("日期", record.date),
                                y: .value("体重", record.weight)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 200)
                        .chartYAxisLabel("体重 (kg)")
                        .chartXAxisLabel("日期")
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                
                // Statistics
                WeightStatisticsView(records: sortedWeightRecords)
                
                // Records List
                WeightRecordsListView(records: sortedWeightRecords.reversed())
            }
            .padding()
        }
        .navigationTitle("\(pet.name) 体重记录")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct WeightStatisticsView: View {
    let records: [WeightRecord]
    
    private var minWeight: Double {
        records.map(\.weight).min() ?? 0
    }
    
    private var maxWeight: Double {
        records.map(\.weight).max() ?? 0
    }
    
    private var avgWeight: Double {
        let sum = records.map(\.weight).reduce(0, +)
        return records.isEmpty ? 0 : sum / Double(records.count)
    }
    
    private var weightChange: Double? {
        guard records.count >= 2 else { return nil }
        return records.last!.weight - records.first!.weight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("统计信息")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "最低体重", value: String(format: "%.1f kg", minWeight), color: .blue)
                StatCard(title: "最高体重", value: String(format: "%.1f kg", maxWeight), color: .orange)
                StatCard(title: "平均体重", value: String(format: "%.1f kg", avgWeight), color: .green)
                
                if let change = weightChange {
                    StatCard(
                        title: "总变化",
                        value: String(format: "%@%.1f kg", change >= 0 ? "+" : "", change),
                        color: change >= 0 ? .green : .red
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct WeightRecordsListView: View {
    let records: [WeightRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("历史记录")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(records) { record in
                    WeightRecordRow(record: record)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct WeightRecordRow: View {
    let record: WeightRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.1f kg", record.weight))
                    .font(.body)
                    .fontWeight(.semibold)
                
                if let notes = record.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
    }
}
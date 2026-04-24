//
//  MedicalRecordsView.swift
//  PawRoutine
//
//  医疗记录 - 从 PawRoutine2 回滚
//

import SwiftUI
import SwiftData

struct MedicalRecordsView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showAddMedical = false
    @State private var selectedTab: MedicalTab = .vaccine
    
    enum MedicalTab: String, CaseIterable {
        case vaccine = "疫苗记录"
        case deworm = "驱虫记录"
    }
    
    private var filteredRecords: [MedicalRecord] {
        pet.medicalRecords
            .filter { record in
                switch selectedTab {
                case .vaccine:
                    return record.type == .vaccination
                case .deworm:
                    return record.type == .dewormingInternal || record.type == .dewormingExternal
                }
            }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 疫苗/驱虫切换
                tabPicker
                
                // 记录列表
                recordsList
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
        .navigationTitle("医疗记录")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddMedical = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showAddMedical) {
            AddMedicalRecordView(pet: pet)
        }
    }
    
    // MARK: - Tab Picker
    
    private var tabPicker: some View {
        Picker("类型", selection: $selectedTab) {
            ForEach(MedicalTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, PawRoutineTheme.Spacing.lg)
        .padding(.top, PawRoutineTheme.Spacing.sm)
    }
    
    // MARK: - Records List
    
    private var recordsList: some View {
        VStack(spacing: PawRoutineTheme.Spacing.lg) {
            if filteredRecords.isEmpty {
                PREmptyState(
                    icon: "cross.case.fill",
                    title: "暂无\(selectedTab.rawValue)",
                    subtitle: "点击右上角添加记录"
                )
                .padding(.top, 40)
            } else {
                ForEach(filteredRecords) { record in
                    MedicalRecordCard(record: record)
                }
            }
        }
    }
}

// MARK: - Medical Record Card

struct MedicalRecordCard: View {
    let record: MedicalRecord
    
    private var typeColor: Color {
        switch record.type {
        case .vaccination: return .blue
        case .dewormingInternal, .dewormingExternal: return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
                // 标题行
                HStack {
                    Text(record.title)
                        .font(PawRoutineTheme.PRFont.title3(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    // 已完成标签
                    Text("已完成")
                        .font(PawRoutineTheme.PRFont.caption2(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(PawRoutineTheme.Colors.secondary.opacity(0.12), in: Capsule())
                }
                
                // 日期信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("上次接种")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                            .frame(width: 70, alignment: .leading)
                        
                        Text(record.date, format: .dateTime.year().month().day())
                            .font(PawRoutineTheme.PRFont.bodyText())
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                        
                        Spacer()
                    }
                    
                    if let nextDue = record.nextDueDate {
                        HStack {
                            Text("下次接种")
                                .font(PawRoutineTheme.PRFont.caption())
                                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                                .frame(width: 70, alignment: .leading)
                            
                            Text(nextDue, format: .dateTime.year().month().day())
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

//
//  MedicalRecordsView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData

struct MedicalRecordsView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showAddMedical = false
    @State private var selectedTab: MedicalTab = .all
    @State private var selectedRecord: MedicalRecord?
    
    enum MedicalTab: String, CaseIterable {
        case all = "All"
        case vaccine = "Vaccine"
        case deworm = "Deworm"
        case checkup = "Checkup"
        case other = "Other"
        
        var displayName: String {
            NSLocalizedString(rawValue, comment: "Medical tab")
        }
    }
    
    private var filteredRecords: [MedicalRecord] {
        pet.medicalRecords
            .filter { record in
                switch selectedTab {
                case .all: return true
                case .vaccine: return record.type == .vaccination
                case .deworm: return record.type == .dewormingInternal || record.type == .dewormingExternal
                case .checkup: return record.type == .checkup
                case .other: return record.type == .treatment || record.type == .certificate || record.type == .surgery || record.type == .other
                }
            }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: PawRoutineTheme.Spacing.lg) {
                    tabPicker
                    recordsList
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.bottom, PawRoutineTheme.Spacing.xxxl)
            }
        }
        .navigationTitle("Medical Records")
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
        .sheet(item: $selectedRecord) { record in
            EditMedicalRecordView(record: record, pet: pet)
        }
    }
    
    private var tabPicker: some View {
        HStack(spacing: 4) {
            ForEach(MedicalTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.displayName)
                        .font(PawRoutineTheme.PRFont.caption(.semibold))
                        .foregroundColor(selectedTab == tab ? .white : PawRoutineTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == tab
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
    
    private var recordsList: some View {
        VStack(spacing: PawRoutineTheme.Spacing.lg) {
            if filteredRecords.isEmpty {
                let emptyTitle = String(format: NSLocalizedString("暂无%@记录", comment: ""), selectedTab.displayName)
                PREmptyState(
                    icon: "cross.case.fill",
                    title: LocalizedStringKey(emptyTitle),
                    subtitle: "Tap top-right to add a record"
                )
                .padding(.top, 40)
            } else {
                ForEach(filteredRecords) { record in
                    MedicalRecordCard(record: record)
                        .onTapGesture {
                            selectedRecord = record
                        }
                        .contextMenu {
                            Button {
                                selectedRecord = record
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                deleteRecord(record)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
    
    private func deleteRecord(_ record: MedicalRecord) {
        if let index = pet.medicalRecords.firstIndex(where: { $0.id == record.id }) {
            pet.medicalRecords.remove(at: index)
        }
        modelContext.delete(record)
        try? modelContext.save()
    }
}

struct MedicalRecordCard: View {
    let record: MedicalRecord
    
    private var typeColor: Color {
        switch record.type {
        case .vaccination: return .blue
        case .dewormingInternal, .dewormingExternal: return .orange
        case .checkup: return .green
        case .treatment: return .red
        case .certificate: return .purple
        case .surgery: return .pink
        case .other: return .gray
        }
    }
    
    var body: some View {
        PRCard(padding: .init(top: 14, leading: 14, bottom: 14, trailing: 14)) {
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                // Type icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(typeColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: record.type.systemImage)
                        .font(.system(size: 20))
                        .foregroundStyle(typeColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(record.title)
                            .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                        
                        Spacer()
                        
                        Text("Completed")
                            .font(PawRoutineTheme.PRFont.caption2(.semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.walking)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(PawRoutineTheme.Colors.walking.opacity(0.12), in: Capsule())
                    }
                    
                    HStack(spacing: PawRoutineTheme.Spacing.xl) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Last")
                                .font(PawRoutineTheme.PRFont.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            Text(record.date, format: .dateTime.year().month().day())
                                .font(PawRoutineTheme.PRFont.caption(.medium))
                                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                        }
                        
                        if let nextDue = record.nextDueDate {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Next")
                                    .font(PawRoutineTheme.PRFont.caption2())
                                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                Text(nextDue, format: .dateTime.year().month().day())
                                    .font(PawRoutineTheme.PRFont.caption(.medium))
                                    .foregroundStyle(typeColor)
                            }
                        }
                    }
                }
            }
        }
    }
}

//
//  ProfileDetailView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import SwiftData
import Charts

struct ProfileDetailView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var showAddWeight = false
    @State private var showMedicalRecord = false
    @State private var showDocumentPicker = false
    
    // 体重追踪相关状态
    @State private var newWeight: String = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                // MARK: - 基础信息卡片
                profileHeader
                
                // MARK: - 年龄与信息详情
                infoCards
                
                // MARK: - 体重追踪
                weightSection
                
                // MARK: - 医疗记录
                medicalSection
                
                // MARK: - 证件夹
                documentsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(
            LinearGradient(
                colors: [PawRoutineTheme.Colors.gradientTop, PawRoutineTheme.Colors.gradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showEditSheet) {
            EditPetView(pet: pet)
        }
        .sheet(isPresented: $showAddWeight) {
            AddWeightSheet(pet: pet)
        }
        .sheet(isPresented: $showMedicalRecord) {
            AddMedicalRecordSheet(pet: pet)
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        GlassCard {
            HStack(spacing: 16) {
                // 头像
                if let avatar = pet.avatarImage {
                    avatar
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [PawRoutineTheme.Colors.primary, PawRoutineTheme.Colors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: PawRoutineTheme.Colors.primary.opacity(0.2), radius: 10, y: 4)
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [PawRoutineTheme.Colors.primary.opacity(0.15), PawRoutineTheme.Colors.secondary.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: pet.petType.icon)
                            .font(.system(size: 32))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                }
                
                // 基本信息
                VStack(alignment: .leading, spacing: 6) {
                    Text(pet.name)
                        .font(.title2.weight(.bold))
                    
                    HStack(spacing: 8) {
                        if !pet.breed.isEmpty {
                            Label(pet.breed, systemImage: "tag.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Label(pet.petType.rawValue, systemImage: pet.petType.icon)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        // 性别
                        HStack(spacing: 4) {
                            Image(systemName: pet.gender.icon)
                                .font(.caption)
                            Text(pet.gender.rawValue)
                                .font(.caption)
                        }
                        
                        // 绝育状态
                        HStack(spacing: 4) {
                            Image(systemName: pet.isNeutered ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(pet.isNeutered ? PawRoutineTheme.Colors.secondary : .orange)
                            Text(pet.isNeutered ? "已绝育" : "未绝育")
                                .font(.caption)
                                .foregroundStyle(pet.isNeutered ? PawRoutineTheme.Colors.secondary : .orange)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 编辑按钮
                Button { showEditSheet = true } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.6))
                }
            }
        }
    }
    
    // MARK: - Info Cards (Age Calculator)
    
    private var infoCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            // 年龄卡片
            GlassCard(cornerRadius: 16, padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("年龄", systemImage: "birthday.cake.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    if let ageString = pet.ageDisplayString {
                        Text(ageString)
                            .font(.title3.weight(.bold))
                        
                        if let humanAge = pet.humanAge {
                            Text("≈ \(String(format: "%.1f", humanAge)) 岁人类年龄")
                                .font(.caption2)
                                .foregroundStyle(PawRoutineTheme.Colors.secondary)
                        }
                    } else {
                        Text("未设置生日")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 入驻天数卡片
            GlassCard(cornerRadius: 16, padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("入驻天数", systemImage: "calendar.badge.clock")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    let days = Calendar.current.dateComponents([.day], from: pet.createdAt, to: Date()).day ?? 0
                    Text("\(days) 天")
                        .font(.title3.weight(.bold))
                    
                    Text("加入 PawRoutine")
                        .font(.caption2)
                        .foregroundStyle(PawRoutineTheme.Colors.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 总记录数
            GlassCard(cornerRadius: 16, padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("总记录", systemImage: "list.bullet.clipboard.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(pet.dailyRecords.count)")
                        .font(.title3.weight(.bold))
                    
                    Text("条日常记录")
                        .font(.caption2)
                        .foregroundStyle(PawRoutineTheme.Colors.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 医疗记录数
            GlassCard(cornerRadius: 16, padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("医疗", systemImage: "cross.case.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(pet.medicalRecords.count)")
                        .font(.title3.weight(.bold))
                    
                    Text("条医疗记录")
                        .font(.caption2)
                        .foregroundStyle(PawRoutineTheme.Colors.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Weight Section
    
    private var weightSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("体重追踪", systemImage: "scalemass.fill")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let latest = pet.weightRecords.sorted(by: { $0.timestamp > $1.timestamp }).first {
                        Text("\(latest.weight, specifier: "%.1f") kg")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(PawRoutineTheme.Colors.secondary)
                    }
                    
                    Button { showAddWeight = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                }
                
                if pet.weightRecords.isEmpty {
                    Text("还没有体重记录，点击 + 添加")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else {
                    WeightChart(records: pet.weightRecords.sorted(by: { $0.timestamp < $1.timestamp }))
                        .frame(height: 180)
                }
            }
        }
    }
    
    // MARK: - Medical Records Section
    
    private var medicalSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("医疗备忘录", systemImage: "cross.case.fill")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button { showMedicalRecord = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                }
                
                if pet.medicalRecords.isEmpty {
                    Text("还没有医疗记录")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    ForEach(pet.medicalRecords.sorted(by: { $0.date > $1.date }).prefix(5)) { record in
                        MedicalRecordRow(record: record)
                    }
                }
            }
        }
    }
    
    // MARK: - Documents Section
    
    private var documentsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("证件夹", systemImage: "folder.fill.badge.plus")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(pet.documents.count) 个文件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if pet.documents.isEmpty {
                    Text("还没有保存的证件照片")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(pet.documents) { doc in
                            DocumentThumbnail(document: doc)
                        }
                    }
                }
                
                // 添加文档按钮
                Button {
                    showDocumentPicker = true
                } label: {
                    Label("添加证件照片", systemImage: "camera.on.rectangle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(PawRoutineTheme.Colors.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            AddDocumentSheet(pet: pet)
        }
    }
}

// MARK: - Weight Chart

struct WeightChart: View {
    let records: [WeightRecord]
    
    var body: some View {
        Chart(records) { record in
            PointMark(
                x: .value("日期", record.timestamp),
                y: .value("体重", record.weight)
            )
            .foregroundStyle(PawRoutineTheme.Colors.secondary)
            .annotation(position: .overlay) {
                if records.count <= 7 {
                    Text(record.weight, format: .number.precision(.fractionLength(1)))
                        .font(.caption2)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel(centered: true) {
                    Text("\(value.as(Double.self) ?? 0, specifier: "%.1f")")
                        .font(.caption2)
                }
            }
        }
        .chartXAxis(.hidden)
    }
}

// MARK: - Medical Record Row

struct MedicalRecordRow: View {
    let record: MedicalRecord
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(colorFor(record.medicalType).opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: record.medicalType.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(colorFor(record.medicalType))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(.subheadline.weight(.medium))
                
                HStack(spacing: 8) {
                    Text(record.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let nextDue = record.nextDueDate {
                        Label("下次: \(nextDue, style: .date)", systemImage: "clock.arrow.circlepath")
                            .font(.caption2)
                            .foregroundStyle(record.isReminderSet ? PawRoutineTheme.Colors.accent : Color(.gray.opacity(0.4)))
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func colorFor(_ type: MedicalType) -> Color {
        switch type {
        case .vaccination: return .blue
        case .dewormingInternal: return .red
        case .dewormingExternal: return .orange
        case .checkup: return .green
        case .surgery: return .purple
        case .other: return .gray
        }
    }
}

// MARK: - Document Thumbnail

struct DocumentThumbnail: View {
    let document: Document
    
    var body: some View {
        VStack(spacing: 6) {
            if let imageData = document.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 80)
                    .overlay(
                        Image(systemName: document.documentType.icon)
                            .font(.title2)
                            .foregroundStyle(.gray)
                    )
            }
            
            Text(document.title)
                .font(.caption2)
                .lineLimit(1)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try? ModelContainer(for: Pet.self, configurations: config)
    
    guard let container else {
        return Text("Failed to create preview")
    }
    
    let context = container.mainContext
    let samplePet = Pet(name: "旺财", breed: "柯基", petType: .dog, gender: .male, isNeutered: true)
    context.insert(samplePet)
    
    return ProfileDetailView(pet: samplePet)
        .modelContainer(container)
}

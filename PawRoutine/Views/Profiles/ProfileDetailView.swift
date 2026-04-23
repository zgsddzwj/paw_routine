//
//  ProfileDetailView.swift
//  PawRoutine
//
//  宠物档案详情 - 设计稿还原
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
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // MARK: - 头部信息卡片
                profileHeader
                
                // MARK: - 年龄与信息详情
                infoCardsSection
                
                // MARK: - 体重追踪
                weightSection
                
                // MARK: - 医疗记录
                medicalSection
                
                // MARK: - 证件夹
                documentsSection
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
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
    
    // MARK: - Profile Header (设计稿顶部大头像 + 信息)
    
    private var profileHeader: some View {
        PRCard(padding: .init(top: 20, leading: 16, bottom: 16, trailing: 16)) {
            HStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 头像
                PRPetAvatar(image: pet.avatarImage, size: 80, showBorder: true)
                
                // 基本信息
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(pet.name)
                            .font(PawRoutineTheme.PRFont.title1(.bold))
                        
                        Button { showEditSheet = true } label: {
                            Image(systemName: "pencil")
                                .font(.caption2)
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        if !pet.breed.isEmpty {
                            PRTag(text: pet.breed, color: PawRoutineTheme.Colors.textSecondary)
                        }
                        
                        PRTag(text: pet.petType.rawValue, color: PawRoutineTheme.Colors.primary.opacity(0.5))
                    }
                    
                    HStack(spacing: 12) {
                        Label(pet.gender.rawValue, systemImage: pet.gender.icon)
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        
                        Text("·")
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        
                        Text(pet.isNeutered ? "已绝育" : "未绝育")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(pet.isNeutered ? PawRoutineTheme.Colors.secondary : PawRoutineTheme.Colors.accent)
                    }
                }
                
                Spacer()
                
                // 小狗插图区域（设计稿右侧）
                if let avatar = pet.avatarImage {
                    avatar
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .opacity(0.3)
                } else {
                    Image(systemName: pet.petType.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.15))
                }
            }
        }
    }
    
    // MARK: - Info Cards Section (年龄 + 入驻天数 + 统计)
    
    private var infoCardsSection: some View {
        VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
            // 年龄 + 生日 行
            PRCard(padding: .init(top: 14, leading: 14, bottom: 14, trailing: 14)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("年龄")
                            .font(PawRoutineTheme.PRFont.caption(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        
                        if let ageString = pet.ageDisplayString {
                            Text(ageString)
                                .font(PawRoutineTheme.PRFont.title2(.bold))
                            
                            if let humanAge = pet.humanAge {
                                Text("≈ \(String(format: "%.1f", humanAge)) 岁（人类年龄）")
                                    .font(PawRoutineTheme.PRFont.caption2())
                                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            }
                        } else {
                            Text("未设置生日")
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("出生日期")
                            .font(PawRoutineTheme.PRFont.caption(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        
                        if let birthDate = pet.birthDate {
                            Text(birthDate, format: .dateTime.year().month().day())
                                .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        } else {
                            Text("-")
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    }
                }
            }
            
            // 底部统计行：总记录 | 医疗 | 证件
            HStack(spacing: PawRoutineTheme.Spacing.sm) {
                statItem(title: "今日", value: "\(pet.todayRecords.count)", icon: "calendar", color: PawRoutineTheme.Colors.primary)
                statItem(title: "档案", value: "\(pet.medicalRecords.count)", icon: "cross.case.fill", color: PawRoutineTheme.Colors.medication)
                statItem(title: "证件", value: "\(pet.documents.count)", icon: "folder.fill", color: PawRoutineTheme.Colors.feeding)
                statItem(title: "统计", value: "-", icon: "chart.bar.fill", color: PawRoutineTheme.Colors.walking)
            }
        }
    }
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        PRCard(padding: .init(top: 10, leading: 10, bottom: 10, trailing: 10)) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                
                Text(value)
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                
                Text(title)
                    .font(PawRoutineTheme.PRFont.micro())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Weight Section (设计稿体重追踪)
    
    private var weightSection: some View {
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
                // 标题栏
                HStack {
                    PRSectionHeader("体重追踪") { trailing in
                        Button { showAddWeight = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(PawRoutineTheme.Colors.primary)
                        }
                    }
                }
                
                if pet.weightRecords.isEmpty {
                    Text("还没有体重记录，点击 + 添加")
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else {
                    // 最新体重 + 变化
                    let sortedWeights = pet.weightRecords.sorted(by: { $0.timestamp < $1.timestamp })
                    if let latest = sortedWeights.last,
                       let previous = sortedWeights.dropLast().last {
                        HStack(spacing: PawRoutineTheme.Spacing.sm) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("最新体重")
                                    .font(PawRoutineTheme.PRFont.caption())
                                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                
                                Text("\(latest.weight, specifier: "%.1f") kg")
                                    .font(PawRoutineTheme.PRFont.title2(.bold))
                            }
                            
                            Spacer()
                            
                            let diff = latest.weight - previous.weight
                            let diffStr = String(format: "%.1f", abs(diff))
                            HStack(spacing: 2) {
                                Text(diff >= 0 ? "+" : "-")
                                Text(diffStr)
                                Text("kg ↗")
                            }
                            .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                            .foregroundStyle(diff >= 0 ? PawRoutineTheme.Colors.secondary : PawRoutineTheme.Colors.medication)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((diff >= 0 ? PawRoutineTheme.Colors.secondary : PawRoutineTheme.Colors.medication).opacity(0.08), in: Capsule())
                        }
                    }
                    
                    // 图表
                    WeightChart(records: sortedWeights)
                        .frame(height: 180)
                        .padding(.top, PawRoutineTheme.Spacing.sm)
                    
                    // 历史列表
                    Divider()
                        .padding(.vertical, PawRoutineTheme.Spacing.xs)
                    
                    ForEach(sortedWeights.suffix(4).reversed()) { record in
                        WeightHistoryRow(record: record)
                    }
                }
            }
        }
    }
    
    // MARK: - Medical Records Section
    
    private var medicalSection: some View {
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
                HStack {
                    PRSectionHeader("医疗记录") { trailing in
                        Button { showMedicalRecord = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(PawRoutineTheme.Colors.primary)
                        }
                    }
                }
                
                if pet.medicalRecords.isEmpty {
                    Text("还没有医疗记录")
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
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
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
                HStack {
                    PRSectionHeader("证件夹") { trailing in
                        Text("\(pet.documents.count) 个文件")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                }
                
                if pet.documents.isEmpty {
                    Text("还没有保存的证件照片")
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: PawRoutineTheme.Spacing.md) {
                        ForEach(pet.documents) { doc in
                            DocumentThumbnail(document: doc)
                        }
                    }
                }
                
                // 添加按钮
                Button {
                    showDocumentPicker = true
                } label: {
                    Label("添加证件照片", systemImage: "camera.on.rectangle.fill")
                        .font(PawRoutineTheme.PRFont.bodyText(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(PawRoutineTheme.Colors.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
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
            .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.7))
            .annotation(position: .overlay) {
                if records.count <= 7 {
                    Text(record.weight, format: .number.precision(.fractionLength(1)))
                        .font(PawRoutineTheme.PRFont.caption2())
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel(centered: true) {
                    Text("\(value.as(Double.self) ?? 0, specifier: "%.1f")")
                        .font(PawRoutineTheme.PRFont.micro())
                }
            }
        }
        .chartXAxis(.hidden)
    }
}

// MARK: - Weight History Row

struct WeightHistoryRow: View {
    let record: WeightRecord
    
    var body: some View {
        HStack {
            Text(record.timestamp, format: .dateTime.month().day())
                .font(PawRoutineTheme.PRFont.caption())
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                .frame(width: 50, alignment: .leading)
            
            Spacer()
            
            Text("\(record.weight, specifier: "%.1f") kg")
                .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                .monospacedDigit()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Medical Record Row

struct MedicalRecordRow: View {
    let record: MedicalRecord
    
    var body: some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(colorFor(record.medicalType).opacity(0.10))
                    .frame(width: 36, height: 36)
                
                Image(systemName: record.medicalType.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(colorFor(record.medicalType))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(PawRoutineTheme.PRFont.bodyText(.medium))
                
                HStack(spacing: 8) {
                    Text(record.date, style: .date)
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    
                    if let nextDue = record.nextDueDate {
                        Label("下次: \(nextDue, style: .date)", systemImage: "clock.arrow.circlepath")
                            .font(PawRoutineTheme.PRFont.caption2())
                            .foregroundStyle(record.isReminderSet ? PawRoutineTheme.Colors.secondary : Color(.gray.opacity(0.4)))
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
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
                    .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
            } else {
                RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md)
                    .fill(PawRoutineTheme.Colors.bgSecondary)
                    .frame(height: 80)
                    .overlay(
                        Image(systemName: document.documentType.icon)
                            .font(.title2)
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    )
            }
            
            Text(document.title)
                .font(PawRoutineTheme.PRFont.caption2())
                .lineLimit(1)
                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
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
    let samplePet = Pet(name: "Cookie", breed: "金毛寻回犬", petType: .dog, gender: .male, isNeutered: true)
    context.insert(samplePet)
    
    return ProfileDetailView(pet: samplePet)
        .modelContainer(container)
}

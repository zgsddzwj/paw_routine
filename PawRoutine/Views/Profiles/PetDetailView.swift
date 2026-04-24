//
//  PetDetailView.swift
//  PawRoutine
//
//  宠物档案详情 - 还原设计稿（入口列表式）
//

import SwiftUI
import SwiftData

struct PetDetailView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // MARK: - 头部信息卡片
                profileHeader
                
                // MARK: - 年龄卡片
                ageCard
                
                // MARK: - 功能入口列表
                functionMenu
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
        .navigationTitle("宠物档案")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showEditSheet) {
            EditPetView(pet: pet)
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        PRCard(padding: .init(top: 20, leading: 16, bottom: 16, trailing: 16)) {
            HStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 头像
                petAvatar
                
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
                            Text(pet.breed)
                                .font(PawRoutineTheme.PRFont.caption())
                                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        }
                        
                        Text("·")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        
                        Text(pet.gender.rawValue)
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    }
                    
                    // 绝育标签
                    if pet.isNeutered {
                        Text("已绝育")
                            .font(PawRoutineTheme.PRFont.caption2(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(PawRoutineTheme.Colors.secondary.opacity(0.12), in: Capsule())
                    }
                }
                
                Spacer()
                
                // 小狗插图区域（设计稿右侧）
                Image(systemName: "dog.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.15))
            }
        }
    }
    
    private var petAvatar: some View {
        Group {
            if let imageData = pet.profileImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: 40)
                    .fill(
                        LinearGradient(
                            colors: [
                                PawRoutineTheme.Colors.primary.opacity(0.15),
                                PawRoutineTheme.Colors.secondary.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.4))
                    )
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(PawRoutineTheme.Colors.separator, lineWidth: 1)
        )
    }
    
    // MARK: - Age Card
    
    private var ageCard: some View {
        PRCard(padding: .init(top: 16, leading: 16, bottom: 16, trailing: 16)) {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("年龄")
                            .font(PawRoutineTheme.PRFont.caption(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        
                        Text(pet.ageDescription)
                            .font(PawRoutineTheme.PRFont.title2(.bold))
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                        
                        Text("≈ \(Int(pet.ageInHumanYears)) 岁（人类年龄）")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("出生日期")
                            .font(PawRoutineTheme.PRFont.caption(.medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        
                        Text(pet.birthDate, format: .dateTime.year().month().day())
                            .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Function Menu
    
    private var functionMenu: some View {
        PRCard(padding: .init(top: 4, leading: 16, bottom: 4, trailing: 16)) {
            VStack(spacing: 0) {
                NavigationLink(destination: MedicalRecordsView(pet: pet)) {
                    menuRow(
                        icon: "cross.case.fill",
                        iconColor: .blue,
                        title: "医疗记录",
                        subtitle: "\(pet.medicalRecords.count) 条记录"
                    )
                }
                .buttonStyle(.plain)
                
                Divider()
                
                NavigationLink(destination: WeightTrackingView(pet: pet)) {
                    let latestWeight = pet.weightRecords.sorted(by: { $0.date > $1.date }).first?.weight
                    let weightText = latestWeight != nil ? String(format: "最新 %.1f kg", latestWeight!) : "暂无记录"
                    menuRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .cyan,
                        title: "体重追踪",
                        subtitle: weightText
                    )
                }
                .buttonStyle(.plain)
                
                Divider()
                
                NavigationLink(destination: DocumentsView(pet: pet)) {
                    menuRow(
                        icon: "folder.fill",
                        iconColor: .orange,
                        title: "证件夹",
                        subtitle: "\(pet.documents.count) 个文件"
                    )
                }
                .buttonStyle(.plain)
                
                Divider()
                
                NavigationLink(destination: MemoView(pet: pet)) {
                    menuRow(
                        icon: "note.text",
                        iconColor: .green,
                        title: "备忘录",
                        subtitle: "记录日常点滴"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func menuRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.sm)
                    .fill(iconColor.opacity(0.10))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text(subtitle)
                    .font(PawRoutineTheme.PRFont.caption())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
        }
        .padding(.vertical, 12)
    }
}

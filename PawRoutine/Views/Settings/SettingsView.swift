//
//  SettingsView.swift
//  PawRoutine
//
//  设置页面 - 设计稿还原
//

import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    
    @State private var appSetting: AppSettings?
    
    @State private var showExportSheet = false
    @State private var showIAPSheet = false
    @State private var exportURL: URL?
    
    // 提醒时间
    @State private var morningFeedingTime = Date()
    @State private var eveningFeedingTime = Date()
    @State private var morningWalkTime = Date()
    @State private var eveningWalkTime = Date()
    
    // 开关状态
    @State private var feedingReminderOn = true
    @State private var waterReminderOn = true
    @State private var walkReminderOn = true
    @State private var medicationReminderOn = true
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: PawRoutineTheme.Spacing.lg) {
                    // MARK: - Pro 会员卡片
                    ProFeatureCard(isPro: appSetting?.isPro ?? false) {
                        showIAPSheet = true
                    }
                    
                    // MARK: - 提醒配置
                    PRCard {
                        VStack(spacing: 0) {
                            PRSectionHeader("提醒配置")
                                .padding(.bottom, PawRoutineTheme.Spacing.md)
                            
                            reminderRow("喂食（早餐）", icon: "sunrise.fill", time: $morningFeedingTime, enabled: $feedingReminderOn, color: .orange)
                            Divider().padding(.leading, 40)
                            reminderRow("喂食（晚餐）", icon: "sunset.fill", time: $eveningFeedingTime, enabled: $feedingReminderOn, color: .orange)
                            Divider().padding(.leading, 40)
                            reminderRow("遛狗", icon: "figure.walk", time: $morningWalkTime, enabled: $walkReminderOn, color: .green)
                            Divider().padding(.leading, 40)
                            reminderRow("换水", icon: "drop.fill", time: $eveningWalkTime, enabled: $waterReminderOn, color: .blue)
                        }
                    }
                    
                    // MARK: - 健康提醒
                    PRCard {
                        VStack(spacing: 0) {
                            PRSectionHeader("健康提醒")
                                .padding(.bottom, PawRoutineTheme.Spacing.md)
                            
                            settingsRow(title: "体内驱虫", subtitle: "每 30 天", icon: "cross.case.fill", color: .red) {
                                // TODO
                            }
                            Divider().padding(.leading, 44)
                            settingsRow(title: "疫苗提醒", subtitle: "开启", icon: "syringe.fill", color: .green) {
                                // TODO
                            }
                        }
                    }
                    
                    // MARK: - 数据与备份
                    PRCard {
                        VStack(spacing: 0) {
                            PRSectionHeader("数据与备份")
                                .padding(.bottom, PawRoutineTheme.Spacing.md)
                            
                            settingsRow(title: "iCloud 同步", subtitle: "已开启", icon: "cloud.fill", color: .blue) {
                                // TODO
                            }
                            Divider().padding(.leading, 44)
                            
                            Button {
                                exportCSV()
                            } label: {
                                settingsRowContent(
                                    title: "数据导出",
                                    subtitle: "(CSV)",
                                    icon: "square.and.arrow.up",
                                    color: .gray,
                                    trailing: AnyView(Image(systemName: "chevron.right").font(.caption2).foregroundStyle(PawRoutineTheme.Colors.textTertiary))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // MARK: - 关于
                    PRCard {
                        VStack(spacing: 0) {
                            PRSectionHeader("关于")
                                .padding(.bottom, PawRoutineTheme.Spacing.md)
                            
                            settingsRow(title: "帮助与反馈", subtitle: "", icon: "questionmark.circle.fill", color: .blue) {
                                // TODO
                            }
                            Divider().padding(.leading, 44)
                            settingsRow(title: "关于 PawRoutine", subtitle: "", icon: "info.circle.fill", color: .green) {
                                // TODO
                            }
                        }
                    }
                    
                    // 底部 Tab 栏占位
                    HStack(spacing: 0) {
                        bottomTabItem(icon: "house.fill", label: "今日", isSelected: false)
                        bottomTabItem(icon: "pawprint.fill", label: "档案", isSelected: false)
                        bottomTabItem(icon: "chart.bar.fill", label: "统计", isSelected: false)
                        bottomTabItem(icon: "gearshape.fill", label: "设置", isSelected: true)
                    }
                    .padding(.vertical, 8)
                    .background(PawRoutineTheme.Colors.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg))
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.bottom, PawRoutineTheme.Spacing.xxl)
            }
            .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showIAPSheet) {
                IAPView(appSetting: $appSetting)
            }
            .onAppear { loadSettings() }
        }
    }
    
    // MARK: - Reminder Row
    
    private func reminderRow(_ title: String, icon: String, time: Binding<Date>, enabled: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(title)
                .font(PawRoutineTheme.Font.bodyText())
            
            Spacer()
            
            Text(time.wrappedValue, format: .dateTime.hour().minute())
                .font(PawRoutineTheme.Font.bodyText(.medium))
                .monospacedDigit()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
        }
        .padding(.vertical, 12)
        .opacity(enabled.wrappedValue ? 1.0 : 0.5)
    }
    
    // MARK: - Settings Row
    
    private func settingsRow(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: icon,
                color: color,
                trailing: AnyView(Image(systemName: "chevron.right").font(.caption2).foregroundStyle(PawRoutineTheme.Colors.textTertiary))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func settingsRowContent(title: String, subtitle: String, icon: String, color: Color, trailing: AnyView) -> some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(PawRoutineTheme.Font.bodyText())
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(PawRoutineTheme.Font.caption2())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
            }
            
            Spacer()
            
            trailing
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Bottom Tab Item
    
    private func bottomTabItem(icon: String, label: String, isSelected: Bool) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? PawRoutineTheme.Colors.primary : PawRoutineTheme.Colors.textTertiary)
            
            Text(label)
                .font(PawRoutineTheme.Font.micro(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? PawRoutineTheme.Colors.primary : PawRoutineTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Settings Loading
    
    private func loadSettings() {
        if let existing = settings.first {
            appSetting = existing
            morningFeedingTime = existing.morningFeedingTime
            eveningFeedingTime = existing.eveningFeedingTime
            morningWalkTime = existing.morningWalkTime
            eveningWalkTime = existing.eveningWalkTime
            feedingReminderOn = existing.feedingReminderEnabled
            waterReminderOn = existing.waterReminderEnabled
            walkReminderOn = existing.walkReminderEnabled
            medicationReminderOn = existing.medicationReminderEnabled
        } else {
            let newSetting = AppSettings()
            modelContext.insert(newSetting)
            appSetting = newSetting
        }
    }
    
    // MARK: - CSV Export
    
    private func exportCSV() {
        guard let setting = appSetting else { return }
        
        var csvString = "日期,宠物,类型,备注\n"
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("pawroutine_export_\(Date().timeIntervalSince1970).csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            self.exportURL = fileURL
            showExportSheet = true
        } catch {
            print("Export error: \(error)")
        }
    }
}

// MARK: - Pro Feature Card (设计稿顶部会员卡)

struct ProFeatureCard: View {
    let isPro: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            PRCard(padding: .init(top: 18, leading: 16, bottom: 18, trailing: 16)) {
                HStack(spacing: PawRoutineTheme.Spacing.lg) {
                    // 左侧 Logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.15), .yellow.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: isPro ? "crown.fill" : "pawprint.fill")
                            .font(.title2)
                            .foregroundStyle(isPro ? .yellow : PawRoutineTheme.Colors.primary)
                    }
                    
                    // 中间文字
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("PawRoutine Pro")
                                .font(PawRoutineTheme.Font.title3(.semibold))
                            
                            if isPro {
                                PRTag(text: "已激活", color: .green)
                            }
                        }
                        
                        Text("解锁全部功能，享受完整的养宠生活")
                            .font(PawRoutineTheme.Font.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - IAP View (设计稿 Pro 购买页)

struct IAPView: View {
    @Binding var appSetting: AppSettings?
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var purchaseSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: PawRoutineTheme.Spacing.xxl) {
                Spacer()
                
                // 标题区域
                VStack(spacing: PawRoutineTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.15), .orange.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                    
                    Text("PawRoutine Pro")
                        .font(PawRoutineTheme.Font.largeTitle(.bold))
                    
                    Text("解锁全部功能，享受完整的养宠生活")
                        .font(PawRoutineTheme.Font.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                }
                
                // 功能列表
                PRCard(cornerRadius: PawRoutineTheme.Radius.xl, padding: .init(top: 20, leading: 16, bottom: 20, trailing: 16)) {
                    VStack(alignment: .leading, spacing: 14) {
                        featureItem(icon: "checkmark.circle.fill", title: "无限宠物数量", isChecked: true)
                        featureItem(icon: "checkmark.circle.fill", title: "高级统计图表", isChecked: true)
                        featureItem(icon: "checkmark.circle.fill", title: "数据导出 (CSV)", isChecked: true)
                        featureItem(icon: "checkmark.circle.fill", title: "优先客服支持", isChecked: false)
                        featureItem(icon: "checkmark.circle.fill", title: "未来更多功能", isChecked: false)
                    }
                }
                
                Spacer()
                
                // 价格和购买按钮
                VStack(spacing: PawRoutineTheme.Spacing.md) {
                    if purchaseSuccess {
                        Label("✅ 已成功激活 Pro 版！", systemImage: "checkmark.circle.fill")
                            .font(PawRoutineTheme.Font.title3(.semibold))
                            .foregroundStyle(.green)
                    } else {
                        Button {
                            purchasePro()
                        } label: {
                            Text("¥ 68 实施解锁")
                                .font(PawRoutineTheme.Font.bodyText(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md)
                                        .fill(PawRoutineTheme.Colors.primary)
                                )
                        }
                        .disabled(isLoading)
                        
                        Text("一次购买，永久使用")
                            .font(PawRoutineTheme.Font.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                    
                    if isLoading {
                        ProgressView()
                            .tint(PawRoutineTheme.Colors.primary)
                    }
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.bottom, PawRoutineTheme.Spacing.xl)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .font(PawRoutineTheme.Font.bodyText())
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(PawRoutineTheme.Colors.bgPrimary)
    }
    
    private func featureItem(icon: String, title: String, isChecked: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(isChecked ? .green : PawRoutineTheme.Colors.textTertiary)
            
            Text(title)
                .font(PawRoutineTheme.Font.bodyText())
                .foregroundStyle(isChecked ? PawRoutineTheme.Colors.textPrimary : PawRoutineTheme.Colors.textTertiary)
            
            Spacer()
        }
    }
    
    private func purchasePro() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            appSetting?.isPro = true
            isLoading = false
            purchaseSuccess = true
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Share Sheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}

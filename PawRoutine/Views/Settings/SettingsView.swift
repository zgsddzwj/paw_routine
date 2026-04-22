//
//  SettingsView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
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
            Form {
                // MARK: - 提醒设置
                Section("默认提醒时间") {
                    reminderRow(
                        "早上喂食",
                        icon: "sunrise.fill",
                        time: $morningFeedingTime,
                        enabled: $feedingReminderOn
                    )
                    
                    reminderRow(
                        "晚上喂食",
                        icon: "sunset.fill",
                        time: $eveningFeedingTime,
                        enabled: $feedingReminderOn
                    )
                    
                    reminderRow(
                        "早上遛狗",
                        icon: "figure.walk",
                        time: $morningWalkTime,
                        enabled: $walkReminderOn
                    )
                    
                    reminderRow(
                        "晚上遛狗",
                        icon: "moon.fill",
                        time: $eveningWalkTime,
                        enabled: $walkReminderOn
                    )
                }
                
                // MARK: - 数据管理
                Section("数据管理") {
                    Button {
                        exportCSV()
                    } label: {
                        Label("导出 CSV 数据", systemImage: "square.and.arrow.up")
                    }
                    
                    if let url = exportURL {
                        ShareLink(item: url) {
                            Label("分享导出文件", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                
                // MARK: - Pro 版本
                Section {
                    ProFeatureRow(isPro: appSetting?.isPro ?? false) {
                        showIAPSheet = true
                    }
                }
                
                // MARK: - 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com")!) {
                        Label("GitHub", systemImage: "link")
                    }
                }
            }
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
            .onAppear {
                loadSettings()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func reminderRow(_ title: String, icon: String, time: Binding<Date>, enabled: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(PawRoutineTheme.Colors.primary)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .opacity(enabled.wrappedValue ? 1.0 : 0.5)
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
        
        // 构建 CSV 内容
        var csvString = "日期,宠物,类型,备注\n"
        
        // 获取所有记录（这里简化处理，实际应查询所有 DailyRecord）
        // 由于 SwiftData 的限制，我们使用一个基本结构
        
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

// MARK: - Pro Feature Row

struct ProFeatureRow: View {
    let isPro: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.yellow.opacity(0.2), .orange.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isPro ? "crown.fill" : "crown")
                        .font(.title3)
                        .foregroundStyle(isPro ? .yellow : .orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(isPro ? "PawRoutine Pro" : "升级到 Pro")
                            .font(.subheadline.weight(.semibold))
                        
                        if isPro {
                            Text("已激活")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(.green))
                        }
                    }
                    
                    Text("解锁无限宠物、高级图表和数据导出")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - IAP View

struct IAPView: View {
    @Binding var appSetting: AppSettings?
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var purchaseSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // 标题区域
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("PawRoutine Pro")
                        .font(.title.bold())
                    
                    Text("一次购买，永久使用")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 功能列表
                GlassCard(cornerRadius: 16, padding: 0) {
                    VStack(alignment: .leading, spacing: 14) {
                        featureItem(icon: "infinity", title: "无限宠物数量", subtitle: "添加任意数量的宠物档案")
                        featureItem(icon: "chart.pie", title: "高级统计图表", subtitle: "更详细的健康趋势分析")
                        featureItem(icon: "doc.text", title: "数据导出功能", subtitle: "导出完整记录为 CSV 文件")
                        featureItem(icon: "sparkles", title: "更多主题样式", subtitle: "即将推出")
                    }
                }
                .padding(20)
                
                Spacer()
                
                // 价格和购买按钮
                VStack(spacing: 12) {
                    if purchaseSuccess {
                        Label("✅ 已成功激活 Pro 版！", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                    } else {
                        Button {
                            purchasePro()
                        } label: {
                            Text("¥ 18.00 · 买断解锁")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [PawRoutineTheme.Colors.primary, PawRoutineTheme.Colors.secondary],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: PawRoutineTheme.Colors.primary.opacity(0.3), radius: 10, y: 4)
                                )
                        }
                        .disabled(isLoading)
                        
                        if isLoading {
                            ProgressView()
                                .tint(PawRoutineTheme.Colors.primary)
                        }
                    }
                    
                    Text("购买即表示同意服务条款和隐私政策")
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(
            LinearGradient(
                colors: [PawRoutineTheme.Colors.gradientTop, PawRoutineTheme.Colors.gradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func featureItem(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(PawRoutineTheme.Colors.primary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(PawRoutineTheme.Colors.secondary)
        }
    }
    
    private func purchasePro() {
        isLoading = true
        
        // 模拟 IAP 购买流程（实际项目中需要接入 StoreKit 2）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // 模拟购买成功
            appSetting?.isPro = true
            isLoading = false
            purchaseSuccess = true
            
            // 触觉反馈
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

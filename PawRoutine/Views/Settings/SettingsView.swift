//
//  SettingsView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query private var pets: [Pet]
    
    @State private var showingExportSheet = false
    @State private var showingProSheet = false
    @State private var showingClearAlert = false
    
    private var currentSettings: AppSettings {
        settings.first ?? {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Card
                    SettingsProfileCard(settings: currentSettings)
                    
                    // Notification Settings Section
                    SettingsSection(title: "提醒默认值", icon: "bell.fill") {
                        SettingsRow(icon: "fork.knife", title: "喂食（早餐）", value: currentSettings.morningFeedingTime.formatted(date: .omitted, time: .shortened)) {
                            // Tapped - could show picker
                        }
                        
                        SettingsRow(icon: "fork.knife", title: "喂食（晚餐）", value: currentSettings.eveningFeedingTime.formatted(date: .omitted, time: .shortened)) {
                            // Tapped
                        }
                        
                        if let walkTime = currentSettings.walkingTimes.first {
                            SettingsRow(icon: "figure.walk", title: "遛狗", value: walkTime.formatted(date: .omitted, time: .shortened)) {
                                // Tapped
                            }
                        }
                        
                        SettingsRow(icon: "drop.fill", title: "换水", value: "09:00") {
                            // Tapped
                        }
                    }
                    
                    // Health Reminders Section
                    SettingsSection(title: "健康提醒", icon: "heart.text.square.fill") {
                        SettingsRow(icon: "pills", title: "体内驱虫", value: "每 90 天") {
                            // Tapped
                        }
                        
                        SettingsRow(icon: "ladybug", title: "体外驱虫", value: "每 30 天") {
                            // Tapped
                        }
                        
                        SettingsRow(icon: "syringe", title: "疫苗提醒", value: currentSettings.medicationReminderEnabled ? "开启" : "关闭") {
                            // Tapped
                        }
                    }
                    
                    // Data Management Section
                    SettingsSection(title: "数据与备份", icon: "square.and.arrow.up") {
                        SettingsRow(icon: "icloud", title: "iCloud 同步", value: "已开启") {
                            // Tapped
                        }
                        
                        Button(action: { showingExportSheet = true }) {
                            SettingsRow(icon: "doc.text", title: "数据导出 (CSV)", value: nil) {}
                                .foregroundColor(.primary)
                        }
                        .disabled(pets.isEmpty)
                    }
                    
                    // About Section
                    SettingsSection(title: "关于", icon: "info.circle.fill") {
                        SettingsRow(icon: "questionmark.circle", title: "帮助与反馈", value: nil) {
                            // Open help URL
                        }
                        
                        SettingsRow(icon: "star.fill", title: "关于 PawRoutine", value: nil) {
                            // Show about
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .sheet(isPresented: $showingExportSheet) {
            DataExportView(pets: pets)
        }
        .sheet(isPresented: $showingProSheet) {
            ProUpgradeView(settings: currentSettings)
        }
        .alert("清除所有数据", isPresented: $showingClearAlert) {
            Button("取消", role: .cancel) {}
            Button("确认删除", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("此操作将删除所有宠物档案和相关记录，且无法恢复。")
        }
    }
    
    private func clearAllData() {
        for pet in pets {
            modelContext.delete(pet)
        }
    }
}

// MARK: - Profile Card
struct SettingsProfileCard: View {
    let settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 16) {
            // App Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "pawprint.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("PawRoutine \(settings.isPro ? "Pro" : "")")
                    .font(.headline)
                
                Text(settings.isPro ? "已解锁" : "免费版")
                    .font(.subheadline)
                    .foregroundColor(settings.isPro ? .green : .secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            // Could navigate to profile
        }
    }
}

// MARK: - Reusable Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                
                Spacer()
                
                if let value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Export View (Full CSV Implementation)
struct DataExportView: View {
    let pets: [Pet]
    @Environment(\.dismiss) private var dismiss
    @State private var exportStatus = ""
    @State private var isExporting = false
    @State private var selectedPet: Pet?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("导出数据")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("将宠物记录导出为CSV文件，方便发送给兽医查看")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Pet Selection
                    if pets.count > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("选择宠物")
                                .font(.headline)
                            
                            Picker("选择宠物", selection: $selectedPet) {
                                Text("全部宠物").tag(nil as Pet?)
                                ForEach(pets) { pet in
                                    Text(pet.name).tag(pet as Pet?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Export Status
                    if !exportStatus.isEmpty {
                        Text(exportStatus)
                            .font(.subheadline)
                            .padding()
                            .background(exportStatus.contains("成功") || exportStatus.contains("已保存") ? Color.green.opacity(0.1) : Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(exportStatus.contains("成功") || exportStatus.contains("已保存") ? .green : .orange)
                    }
                    
                    // Export Button
                    Button(action: exportData) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .tint(.white)
                                Text("导出中...")
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("开始导出")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isExporting ? Color.gray : Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isExporting || pets.isEmpty)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("数据导出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if pets.count == 1 {
                selectedPet = pets.first
            }
        }
    }
    
    private func exportData() {
        isExporting = true
        exportStatus = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let petsToExport: [Pet]
            if let selected = selectedPet {
                petsToExport = [selected]
            } else {
                petsToExport = pets
            }
            
            var csvString = "宠物,类型,活动/记录,时间,备注\n"
            
            for pet in petsToExport {
                // Activities
                for activity in pet.activities.sorted(by: { $0.timestamp < $1.timestamp }) {
                    let dateStr = activity.timestamp.formatted(date: .numeric, time: .standard)
                    let notes = activity.notes ?? ""
                    csvString += "\(pet.name),活动,\(activity.type.rawValue),\(dateStr),\"\(notes)\"\n"
                }
                
                // Medical Records
                for record in pet.medicalRecords.sorted(by: { $0.date < $1.date }) {
                    let dateStr = record.date.formatted(date: .numeric, time: .omitted)
                    let nextDue = record.nextDueDate?.formatted(date: .numeric, time: .omitted) ?? ""
                    let notes = record.notes ?? ""
                    csvString += "\(pet.name),医疗,\(record.type.rawValue),\(dateStr),\"\(notes); 下次:\(nextDue)\"\n"
                }
                
                // Weight Records
                for weight in pet.weightRecords.sorted(by: { $0.date < $1.date }) {
                    let dateStr = weight.date.formatted(date: .numeric, time: .omitted)
                    let notes = weight.notes ?? ""
                    csvString += "\(pet.name),体重,\(weight.weight) kg,\(dateStr),\"\(notes)\"\n"
                }
            }
            
            DispatchQueue.main.async {
                saveCSVFile(csvContent: csvString)
                isExporting = false
            }
        }
    }
    
    private func saveCSVFile(csvContent: String) {
        let fileName = "PawRoutine_Export_\(Date().formatted(date: .numeric, time: .omitted)).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: [])
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
                exportStatus = "已保存到文件App，请通过分享功能导出"
            } else {
                exportStatus = "文件已生成：\(fileName)"
            }
        } catch {
            exportStatus = "导出失败：\(error.localizedDescription)"
        }
    }
}

// MARK: - Pro Upgrade View (Matching Design)
struct ProUpgradeView: View {
    let settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)
                    
                    // Header with Paw Icon
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, .pink]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text("PawRoutine Pro")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("解锁全部功能，宠爱科学的养宠生活")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Features List
                    VStack(spacing: 14) {
                        ProFeatureRow(isChecked: true, title: "无限宠物数量", subtitle: "不再限制宠物数量")
                        ProFeatureRow(isChecked: true, title: "高级统计图表", subtitle: "更丰富的数据分析")
                        ProFeatureRow(isChecked: true, title: "数据导出 (CSV)", subtitle: "优先客服支持")
                        ProFeatureRow(isChecked: true, title: "优先客服支持", subtitle: "")
                    }
                    .padding()
                    .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))
                    
                    // Purchase Button
                    Button(action: purchasePro) {
                        Text("¥18 完整解锁")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                    }
                    
                    Text("一次购买，永久使用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    private func purchasePro() {
        settings.isPro = true
        dismiss()
    }
}

struct ProFeatureRow: View {
    let isChecked: Bool
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isChecked ? "checkmark" : "circle")
                .font(.subheadline)
                .foregroundColor(isChecked ? .green : .secondary)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

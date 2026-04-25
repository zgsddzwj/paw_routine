//
//  SettingsView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData
import CloudKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query private var pets: [Pet]
    
    @State private var showingExportSheet = false
    @State private var showingProSheet = false
    @State private var showingClearAlert = false
    @State private var showingReminderSettings = false
    @State private var showingThemeSettings = false
    @State private var showingAboutView = false
    @State private var showingHelpURL = false
    @State private var isReminderEnabled = false
    @State private var showingiCloudInfo = false
    @State private var cloudKitStatus: CKAccountStatus = .couldNotDetermine
    
    private var currentSettings: AppSettings {
        settings.first ?? {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawRoutineTheme.Spacing.xl) {
                        // Pro Card
                        ProSettingsCard(settings: currentSettings, onTap: { showingProSheet = true })
                        
                        // Reminder Defaults
                        SettingsGroup(title: "Reminder Defaults") {
                            Button(action: { showingReminderSettings = true }) {
                                VStack(spacing: 0) {
                                    SettingsRow(
                                        icon: "fork.knife",
                                        iconColor: PawRoutineTheme.Colors.feeding,
                                        title: "Feeding (Breakfast)",
                                        value: currentSettings.morningFeedingTime.formatted(date: .omitted, time: .shortened)
                                    )
                                    SettingsRow(
                                        icon: "fork.knife",
                                        iconColor: PawRoutineTheme.Colors.feeding,
                                        title: "Feeding (Dinner)",
                                        value: currentSettings.eveningFeedingTime.formatted(date: .omitted, time: .shortened)
                                    )
                                    SettingsRow(
                                        icon: "figure.walk",
                                        iconColor: PawRoutineTheme.Colors.walking,
                                        title: "Walking",
                                        value: currentSettings.morningWalkTime.formatted(date: .omitted, time: .shortened)
                                    )
                                    SettingsRow(
                                        icon: "drop.fill",
                                        iconColor: PawRoutineTheme.Colors.water,
                                        title: "Water Change",
                                        value: currentSettings.waterChangeTime.formatted(date: .omitted, time: .shortened)
                                    )
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Health Reminders
                        SettingsGroup(title: "Health Reminders") {
                            Button(action: { showingReminderSettings = true }) {
                                VStack(spacing: 0) {
                                    SettingsRow(
                                        icon: "pills",
                                        iconColor: .purple,
                                        title: "Internal Deworming",
                                        value: String(format: NSLocalizedString("每 %d 天", comment: ""), currentSettings.dewormInternalInterval)
                                    )
                                    SettingsRow(
                                        icon: "ladybug",
                                        iconColor: .orange,
                                        title: "External Deworming",
                                        value: String(format: NSLocalizedString("每 %d 天", comment: ""), currentSettings.dewormExternalInterval)
                                    )
                                    SettingsRow(
                                        icon: "syringe",
                                        iconColor: .red,
                                        title: "Vaccine Reminder",
                                        value: currentSettings.medicationReminderEnabled ? "Enable" : "Close"
                                    )
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Data
                        SettingsGroup(title: "Data & Backup") {
                            let isCloudKitAvailable = cloudKitStatus == .available
                            Button(action: { showingiCloudInfo = true }) {
                                SettingsRow(
                                    icon: "icloud",
                                    iconColor: isCloudKitAvailable ? .cyan : .gray,
                                    title: "iCloud Sync",
                                    value: isCloudKitAvailable ? NSLocalizedString("On", comment: "") : NSLocalizedString("检测中...", comment: "")
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                if IAPManager.shared.isPro || currentSettings.isPro {
                                    showingExportSheet = true
                                } else {
                                    showingProSheet = true
                                }
                            }) {
                                SettingsRow(
                                    icon: "doc.text",
                                    iconColor: .blue,
                                    title: "Data Export (CSV)",
                                    value: nil
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(pets.isEmpty)
                        }
                        
//                        // General
//                        SettingsGroup(title: "通用") {
//                            Button(action: { showingThemeSettings = true }) {
//                                SettingsRow(
//                                    icon: "paintbrush.fill",
//                                    iconColor: .indigo,
//                                    title: "主题模式",
//                                    value: currentSettings.themeMode.rawValue
//                                )
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
                        
                        // Notifications
                        SettingsGroup(title: "Notifications") {
                            Toggle(isOn: $isReminderEnabled) {
                                HStack(spacing: PawRoutineTheme.Spacing.md) {
                                    PRIconContainer(icon: "bell.fill", color: .red, size: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Receive Reminders")
                                            .font(PawRoutineTheme.PRFont.bodyText())
                                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                        if isReminderEnabled {
                                            Text("On")
                                                .font(PawRoutineTheme.PRFont.caption())
                                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                        } else {
                                            Text("Off")
                                                .font(PawRoutineTheme.PRFont.caption())
                                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                        }
                                    }
                                }
                            }
                            .tint(PawRoutineTheme.Colors.primary)
                            .padding(.horizontal, PawRoutineTheme.Spacing.md)
                            .padding(.vertical, 11)
                            .onChange(of: isReminderEnabled) { _, newValue in
                                toggleNotifications(enabled: newValue)
                            }
                            
                            Button(action: openNotificationSettings) {
                                SettingsRow(
                                    icon: "gear",
                                    iconColor: .gray,
                                    title: "System Notification Settings",
                                    value: nil
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // About
                        SettingsGroup(title: "About") {
                            Button(action: { showingHelpURL = true }) {
                                SettingsRow(
                                    icon: "questionmark.circle",
                                    iconColor: .blue,
                                    title: "Help & Feedback",
                                    value: nil
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { showingAboutView = true }) {
                                SettingsRow(
                                    icon: "star.fill",
                                    iconColor: .yellow,
                                    title: "About FurryNote",
                                    value: nil
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.sm)
                    .padding(.bottom, PawRoutineTheme.Spacing.xxxl)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingExportSheet) {
            DataExportView(pets: pets)
        }
        .sheet(isPresented: $showingProSheet) {
            ProUpgradeView(settings: currentSettings)
        }
        .sheet(isPresented: $showingReminderSettings) {
            ReminderSettingsView(settings: currentSettings)
        }
        .sheet(isPresented: $showingThemeSettings) {
            ThemeSettingsView(settings: currentSettings)
        }
        .sheet(isPresented: $showingAboutView) {
            AboutView()
        }
        .sheet(isPresented: $showingHelpURL) {
            HelpView()
        }
        .alert(NSLocalizedString("iCloud Sync", comment: ""), isPresented: $showingiCloudInfo) {
            Button(NSLocalizedString("OK", comment: ""), role: .cancel) {}
        } message: {
            let isCloudKitAvailable = cloudKitStatus == .available
            if isCloudKitAvailable {
                Text("Your data is automatically synced across all devices signed in with the same Apple ID via iCloud.")
            } else {
                Text("Currently using local storage only. Please sign in to iCloud in system settings to enable automatic sync.")
            }
        }
        .onAppear {
            isReminderEnabled = currentSettings.reminderEnabled
            checkCloudKitStatus()
        }
    }
    
    private func checkCloudKitStatus() {
        let container = CKContainer(identifier: "iCloud.com.furrynote.app")
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                self.cloudKitStatus = status
            }
        }
    }
    
    private func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func toggleNotifications(enabled: Bool) {
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        currentSettings.reminderEnabled = true
                        try? modelContext.save()
                        NotificationManager.shared.rescheduleDailyReminders(for: pets, settings: currentSettings)
                    } else {
                        isReminderEnabled = false
                        currentSettings.reminderEnabled = false
                        try? modelContext.save()
                    }
                }
            }
        } else {
            currentSettings.reminderEnabled = false
            try? modelContext.save()
            for pet in pets {
                NotificationManager.shared.removeDailyReminders(for: pet)
            }
        }
    }
}

// MARK: - Pro Card

struct ProSettingsCard: View {
    let settings: AppSettings
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
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
                
                let isPro = IAPManager.shared.isPro || settings.isPro
                VStack(alignment: .leading, spacing: 4) {
                    Text("FurryNote \(isPro ? "Pro" : "")")
                        .font(PawRoutineTheme.PRFont.bodyText(.bold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    
                    if isPro {
                        Text("Unlocked")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.secondary)
                    } else {
                        Text("Free")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            .padding(PawRoutineTheme.Spacing.lg)
            .contentShape(Rectangle())
            .background(PawRoutineTheme.Colors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
            .shadow(
                color: PawRoutineTheme.Shadows.card.color,
                radius: PawRoutineTheme.Shadows.card.radius,
                x: PawRoutineTheme.Shadows.card.x,
                y: PawRoutineTheme.Shadows.card.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Group

struct SettingsGroup<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
            Text(title)
                .font(PawRoutineTheme.PRFont.caption(.semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                .padding(.horizontal, PawRoutineTheme.Spacing.md)
            
            VStack(spacing: 0) {
                content
            }
            .background(PawRoutineTheme.Colors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
            .shadow(
                color: PawRoutineTheme.Shadows.small.color,
                radius: PawRoutineTheme.Shadows.small.radius,
                x: PawRoutineTheme.Shadows.small.x,
                y: PawRoutineTheme.Shadows.small.y
            )
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let value: String?
    
    var body: some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            PRIconContainer(icon: icon, color: iconColor, size: 28)
            
            Text(title)
                .font(PawRoutineTheme.PRFont.bodyText())
                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
            
            Spacer()
            
            if let value {
                Text(LocalizedStringKey(value))
                    .font(PawRoutineTheme.PRFont.caption(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
        }
        .padding(.horizontal, PawRoutineTheme.Spacing.md)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// MARK: - Pro Upgrade View

struct ProUpgradeView: View {
    let settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showErrorAlert = false
    
    private let features = [
        ("Unlimited Pets", "No pet limit"),
        ("Advanced Charts", "Richer data insights"),
        ("Data Export (CSV)", "Export to CSV"),
        ("Custom Reminders", "More flexible reminder settings"),
        ("Priority Support", "Dedicated support channel")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawRoutineTheme.Spacing.xl) {
                        // Hero
                        heroSection
                        
                        // Features
                        featuresSection
                        
                        // Purchase
                        purchaseSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.lg)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .onAppear {
                Task {
                    await IAPManager.shared.fetchProducts()
                }
            }
            .onChange(of: IAPManager.shared.errorMessage) { _, newValue in
                showErrorAlert = newValue != nil
            }
            .alert("Purchase Failed", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {
                    IAPManager.shared.errorMessage = nil
                }
            } message: {
                if let errorMessage = IAPManager.shared.errorMessage {
                    Text(errorMessage)
                } else {
                    Text("Unknown Error")
                }
            }
        }
    }
    
    // MARK: - Hero
    
    private var heroSection: some View {
        VStack(spacing: PawRoutineTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(
                color: .orange.opacity(0.35),
                radius: 20,
                x: 0,
                y: 10
            )
            
            VStack(spacing: PawRoutineTheme.Spacing.sm) {
                Text("FurryNote Pro")
                    .font(PawRoutineTheme.PRFont.title1(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text("Unlock all features for smarter pet care.")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PawRoutineTheme.Spacing.xl)
            }
        }
        .padding(.top, PawRoutineTheme.Spacing.lg)
    }
    
    // MARK: - Features
    
    private var featuresSection: some View {
        PRCard(padding: .init(top: PawRoutineTheme.Spacing.lg, leading: PawRoutineTheme.Spacing.lg, bottom: PawRoutineTheme.Spacing.lg, trailing: PawRoutineTheme.Spacing.lg)) {
            VStack(spacing: PawRoutineTheme.Spacing.md) {
                ForEach(features, id: \.0) { feature in
                    HStack(spacing: PawRoutineTheme.Spacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(PawRoutineTheme.Colors.walking)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(LocalizedStringKey(feature.0))
                                .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                            
                            if !feature.1.isEmpty {
                                Text(LocalizedStringKey(feature.1))
                                    .font(PawRoutineTheme.PRFont.caption())
                                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Purchase
    
    private var purchaseSection: some View {
        VStack(spacing: PawRoutineTheme.Spacing.md) {
            if IAPManager.shared.isPro || settings.isPro {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(PawRoutineTheme.Colors.walking)
                    
                    Text("You have unlocked FurryNote Pro")
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.walking)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(PawRoutineTheme.Colors.walking.opacity(0.1), in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
            } else {
                let priceText = IAPManager.shared.formattedPrice
                let isPriceLoaded = !priceText.isEmpty
                
                Button(action: isPriceLoaded ? purchasePro : reloadProduct) {
                    HStack {
                        if IAPManager.shared.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Spacer()
                        if IAPManager.shared.isLoading {
                            Text(NSLocalizedString("Loading...", comment: ""))
                                .font(PawRoutineTheme.PRFont.bodyText(.bold))
                        } else if isPriceLoaded {
                            HStack(spacing: 4) {
                                    Text(priceText)
                                        .font(PawRoutineTheme.PRFont.bodyText(.bold))
                                    Text("One-time Unlock")
                                        .font(PawRoutineTheme.PRFont.bodyText(.bold))
                                }
                        } else {
                            Text(NSLocalizedString("Unable to get price, tap to retry", comment: ""))
                                .font(PawRoutineTheme.PRFont.bodyText(.bold))
                        }
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                    )
                    .shadow(
                        color: .orange.opacity(0.35),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(IAPManager.shared.isLoading)
                
                Button(action: restorePurchases) {
                    Text("Restore Purchases")
                        .font(PawRoutineTheme.PRFont.caption(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
                .disabled(IAPManager.shared.isLoading)
                
                Text("One-time purchase, forever use.")
                    .font(PawRoutineTheme.PRFont.caption())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(PawRoutineTheme.Colors.separator)
            
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                Text("Secure payment powered by Apple In-App Purchase")
                    .font(PawRoutineTheme.PRFont.caption2())
            }
            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            .padding(.vertical, PawRoutineTheme.Spacing.md)
        }
        .background(PRWarmBackground())
    }
    
    // MARK: - Save
    
    private func purchasePro() {
        Task {
            let success = await IAPManager.shared.purchase()
            if success {
                settings.isPro = true
                try? modelContext.save()
                dismiss()
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            await IAPManager.shared.restorePurchases()
            if IAPManager.shared.isPro {
                settings.isPro = true
                try? modelContext.save()
                dismiss()
            } else {
                IAPManager.shared.errorMessage = NSLocalizedString("No purchase record found", comment: "")
            }
        }
    }
    
    private func reloadProduct() {
        Task {
            await IAPManager.shared.fetchProducts()
        }
    }
}

// MARK: - Data Export View

struct DataExportView: View {
    let pets: [Pet]
    @Environment(\.dismiss) private var dismiss
    @State private var exportStatus = ""
    @State private var isExporting = false
    @State private var exportSuccess = false
    @State private var selectedPet: Pet?
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PawRoutineTheme.Spacing.xxl) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 56))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                        
                        VStack(spacing: PawRoutineTheme.Spacing.sm) {
                            Text("Export Data")
                                .font(PawRoutineTheme.PRFont.title2(.bold))
                            
                            Text("Export pet records to CSV for easy sharing with your vet.")
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        if pets.count > 1 {
                            PRCard {
                                VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
                                    Text("Select Pet")
                                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                                    
                                    Picker("Select Pet", selection: $selectedPet) {
                                        Text("All Pets").tag(nil as Pet?)
                                        ForEach(pets) { pet in
                                            Text(pet.name).tag(pet as Pet?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                        
                        if !exportStatus.isEmpty {
                            Text(LocalizedStringKey(exportStatus))
                                .font(PawRoutineTheme.PRFont.caption())
                                .padding()
                                .background(
                                    exportSuccess
                                    ? Color.green.opacity(0.1)
                                    : Color.orange.opacity(0.1),
                                    in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md, style: .continuous)
                                )
                                .foregroundColor(exportSuccess ? .green : .orange)
                        }
                        
                        Button(action: exportData) {
                            HStack {
                                if isExporting {
                                    ProgressView()
                                        .tint(.white)
                                    Text(NSLocalizedString("Generating...", comment: ""))
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                    Text(NSLocalizedString("Share Export File", comment: ""))
                                }
                            }
                            .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isExporting ? Color.gray : PawRoutineTheme.Colors.primary, in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md, style: .continuous))
                        }
                        .disabled(isExporting || pets.isEmpty)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Data Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
        exportSuccess = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            let petsToExport: [Pet]
            if let selected = selectedPet {
                petsToExport = [selected]
            } else {
                petsToExport = pets
            }
            
            var csvString = "Pet,Type,Activity/Record,Time,Notes\n"
            
            for pet in petsToExport {
                for activity in pet.activities.sorted(by: { $0.timestamp < $1.timestamp }) {
                    let dateStr = activity.timestamp.formatted(date: .numeric, time: .standard)
                    let notes = activity.notes ?? ""
                    csvString += String(format: "\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"\n", pet.name, "Activity", activity.type.rawValue, dateStr, notes)
                }
                
                for record in pet.medicalRecords.sorted(by: { $0.date < $1.date }) {
                    let dateStr = record.date.formatted(date: .numeric, time: .omitted)
                    let nextDue = record.nextDueDate?.formatted(date: .numeric, time: .omitted) ?? ""
                    let notes = record.notes ?? ""
                    let noteStr = nextDue.isEmpty ? notes : "\(notes); Next: \(nextDue)"
                    csvString += String(format: "\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"\n", pet.name, "Medical", record.type.rawValue, dateStr, noteStr)
                }
                
                for weight in pet.weightRecords.sorted(by: { $0.date < $1.date }) {
                    let dateStr = weight.date.formatted(date: .numeric, time: .omitted)
                    let notes = weight.notes ?? ""
                    csvString += String(format: "\"%@\",\"%@\",\"%.1f kg\",\"%@\",\"%@\"\n", pet.name, "Weight", weight.weight, dateStr, notes)
                }
            }
            
            DispatchQueue.main.async {
                shareCSVFile(csvContent: csvString)
                isExporting = false
            }
        }
    }
    
    private func shareCSVFile(csvContent: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "FurryNote_Export_\(dateFormatter.string(from: Date())).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            // iPad 适配
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = UIView()
                popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            // 找到当前最顶层的 view controller（sheet 嵌套时需要）
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                exportStatus = NSLocalizedString("Unable to open share sheet", comment: "")
                exportSuccess = false
                return
            }
            
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            
            topVC.present(activityVC, animated: true)
            exportSuccess = true
        } catch {
            exportStatus = String(format: NSLocalizedString("导出失败：%@", comment: ""), error.localizedDescription)
            exportSuccess = false
        }
    }
}

// MARK: - Pro Feature Row (deprecated, kept for compatibility)

struct ProFeatureRow: View {
    let isChecked: Bool
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18))
                .foregroundColor(isChecked ? .green : .secondary)
                .padding(.top, 1)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PawRoutineTheme.PRFont.bodyText(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                if subtitle != "" {
                    Text(subtitle)
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
            }
            
            Spacer()
        }
    }
}

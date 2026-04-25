//
//  TodayView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject private var petStore: PetStore
    @Query private var pets: [Pet]
    @State private var showingNotifications = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawRoutineTheme.Spacing.xl) {
                        // Notification Permission Banner
                        if notificationStatus == .denied || notificationStatus == .notDetermined {
                            NotificationPermissionBanner(status: $notificationStatus)
                        }
                        
                        // Pet Selector
                        if !pets.isEmpty {
                            PetSelectorView(pets: pets)
                        }
                        
                        // Daily Progress Rings
                        if let selectedPet = petStore.selectedPet {
                            DailyProgressRingsView(pet: selectedPet)
                            
                            TodayTimelineView(pet: selectedPet)
                        } else if pets.isEmpty {
                            EmptyPetView()
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.sm)
                }
            }
            .navigationTitle(NSLocalizedString("Today", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNotifications = true }) {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationsView()
            }
            .onAppear {
                checkNotificationStatus()
            }
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
            }
        }
    }
}

// MARK: - Notification Permission Banner

struct NotificationPermissionBanner: View {
    @Binding var status: UNAuthorizationStatus
    
    var body: some View {
        VStack(spacing: PawRoutineTheme.Spacing.sm) {
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("Enable Reminders", comment: ""))
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    Text(NSLocalizedString("Get daily reminders for feeding, walking, and more", comment: ""))
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: requestPermission) {
                    Text(NSLocalizedString("Enable", comment: ""))
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(PawRoutineTheme.Colors.primary)
                        .cornerRadius(PawRoutineTheme.Radius.md)
                }
            }
        }
        .padding(PawRoutineTheme.Spacing.md)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(PawRoutineTheme.Radius.lg)
    }
    
    private func requestPermission() {
        if status == .denied {
            // Open system settings
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    status = granted ? .authorized : .denied
                }
            }
        }
    }
}

// MARK: - Pet Selector

struct PetSelectorView: View {
    let pets: [Pet]
    @EnvironmentObject private var petStore: PetStore
    @Query private var settings: [AppSettings]
    @State private var showingProSheet = false
    
    private var currentSettings: AppSettings {
        settings.first ?? AppSettings()
    }
    
    private var canAddPet: Bool {
        IAPManager.shared.isPro || currentSettings.isPro || pets.isEmpty
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: PawRoutineTheme.Spacing.lg) {
                ForEach(pets) { pet in
                    PetAvatarItem(
                        pet: pet,
                        isSelected: petStore.selectedPet?.id == pet.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            petStore.selectPet(pet)
                        }
                    }
                }
                
                // Add pet button
                Button(action: {
                    if canAddPet {
                        petStore.showingAddPet = true
                    } else {
                        showingProSheet = true
                    }
                }) {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [PawRoutineTheme.Colors.primary, PawRoutineTheme.Colors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(
                                    color: PawRoutineTheme.Colors.primary.opacity(0.35),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                            
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                .frame(width: 56, height: 56)
                            
                            if canAddPet {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        Text("Add")
                            .font(PawRoutineTheme.PRFont.caption2())
                            .foregroundStyle(canAddPet ? PawRoutineTheme.Colors.primary : PawRoutineTheme.Colors.textTertiary)
                            .frame(height: 34, alignment: .top)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.vertical, PawRoutineTheme.Spacing.sm)
        }
        .sheet(isPresented: $showingProSheet) {
            ProUpgradeView(settings: currentSettings)
        }
    }
}

struct PetAvatarItem: View {
    let pet: Pet
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let imageData = pet.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? PawRoutineTheme.Colors.walking : Color.clear, lineWidth: 3)
                        )
                } else {
                    Circle()
                        .fill(PawRoutineTheme.Colors.bgSecondary)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.5))
                        )
                        .overlay(
                            Circle()
                                .stroke(isSelected ? PawRoutineTheme.Colors.walking : Color.clear, lineWidth: 3)
                        )
                }
                
                if isSelected {
                    Circle()
                        .fill(PawRoutineTheme.Colors.walking)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 18, y: 18)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                }
            }
            
            Text(pet.name)
                .font(PawRoutineTheme.PRFont.caption(.medium))
                .foregroundStyle(isSelected ? PawRoutineTheme.Colors.textPrimary : PawRoutineTheme.Colors.textTertiary)
                .frame(width: 56, height: 34, alignment: .top)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Empty Pet

struct EmptyPetView: View {
    @EnvironmentObject private var petStore: PetStore
    
    var body: some View {
        VStack(spacing: PawRoutineTheme.Spacing.xl) {
            Spacer().frame(height: 40)
            
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.2))
            
            VStack(spacing: PawRoutineTheme.Spacing.sm) {
                Text("No Pet Profiles Yet")
                    .font(PawRoutineTheme.PRFont.title2(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text("Tap the Pets tab below to add your first pet.")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                petStore.showingAddPet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                    Text("Add Pet")
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                }
                .foregroundColor(.white)
                .frame(width: 160, height: 48)
                .background(
                    LinearGradient(
                        colors: [PawRoutineTheme.Colors.primary, PawRoutineTheme.Colors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: PawRoutineTheme.Colors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, PawRoutineTheme.Spacing.xxxl)
    }
}

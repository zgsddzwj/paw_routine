//
//  ProfilesView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData

struct ProfilesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var petStore: PetStore
    @Query private var settings: [AppSettings]
    @Query private var pets: [Pet]
    @State private var showingAddPet = false
    @State private var showingProSheet = false
    
    private var currentSettings: AppSettings {
        settings.first ?? AppSettings()
    }
    
    private var canAddPet: Bool {
        IAPManager.shared.isPro || currentSettings.isPro || pets.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: PawRoutineTheme.Spacing.lg) {
                        if pets.isEmpty {
                            EmptyProfilesView()
                        } else {
                            ForEach(pets) { pet in
                                NavigationLink(destination: PetDetailView(pet: pet)) {
                                    PetProfileCard(pet: pet)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.sm)
                }
            }
            .navigationTitle("Profiles")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if canAddPet {
                            showingAddPet = true
                        } else {
                            showingProSheet = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPet) {
            AddPetView()
        }
        .sheet(isPresented: $showingProSheet) {
            ProUpgradeView(settings: currentSettings)
        }
    }
}

struct PetProfileCard: View {
    let pet: Pet
    
    var body: some View {
        HStack(spacing: PawRoutineTheme.Spacing.lg) {
            // Pet Avatar
            ZStack {
                if let imageData = pet.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                } else {
                    Circle()
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
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.5))
                        )
                }
            }
            
            // Pet Info
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                if !pet.breed.isEmpty {
                    Text(pet.breed)
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Text(pet.gender.displayName)
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    
                    Text("·")
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    
                    Text(pet.isNeutered ? "Neutered" : "Not Neutered")
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
            }
            
            Spacer()
            
            // Age
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: NSLocalizedString("%d岁", comment: ""), pet.ageInDays / 365))
                    .font(PawRoutineTheme.PRFont.title3(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                
                Text(String(format: NSLocalizedString("≈ %.0f 人类岁", comment: ""), pet.ageInHumanYears))
                    .font(PawRoutineTheme.PRFont.caption2())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
        }
        .padding(PawRoutineTheme.Spacing.lg)
        .background(PawRoutineTheme.Colors.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
        .shadow(
            color: PawRoutineTheme.Shadows.card.color,
            radius: PawRoutineTheme.Shadows.card.radius,
            x: PawRoutineTheme.Shadows.card.x,
            y: PawRoutineTheme.Shadows.card.y
        )
    }
}

struct EmptyProfilesView: View {
    var body: some View {
        VStack(spacing: PawRoutineTheme.Spacing.xl) {
            Spacer().frame(height: 60)
            
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.2))
            
            VStack(spacing: PawRoutineTheme.Spacing.sm) {
                Text("No Pet Profiles Yet")
                    .font(PawRoutineTheme.PRFont.title2(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text("Create your first pet profile to start tracking their health and growth.")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PawRoutineTheme.Spacing.xxl)
            }
            
            Spacer()
        }
    }
}

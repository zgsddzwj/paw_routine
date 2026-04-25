//
//  MainTabView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    @EnvironmentObject var petStore: PetStore
    @State private var selectedTab = 0
    @State private var showWelcome = false
    
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Image(systemName: "sun.max.fill")
                        Text("Today")
                    }
                    .tag(0)
                
                ProfilesView()
                    .tabItem {
                        Image(systemName: "pawprint.fill")
                        Text("Profiles")
                    }
                    .tag(1)
                
                InsightsView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Statistics")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(3)
            }
            .accentColor(PawRoutineTheme.Colors.primary)
            
            // Floating Quick Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        petStore.showingQuickAdd = true
                    }) {
                        ZStack {
                            // Outer soft glow
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [PawRoutineTheme.Colors.primary, PawRoutineTheme.Colors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .shadow(
                                    color: PawRoutineTheme.Colors.primary.opacity(0.4),
                                    radius: 16,
                                    x: 0,
                                    y: 8
                                )
                            
                            // Inner subtle border
                            Circle()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $petStore.showingQuickAdd) {
            QuickAddView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $petStore.showingAddPet) {
            AddPetView()
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView(showWelcome: $showWelcome)
        }
        .onAppear {
            // Ensure AppSettings exists
            if (try? modelContext.fetchCount(FetchDescriptor<AppSettings>())) == 0 {
                let newSettings = AppSettings()
                modelContext.insert(newSettings)
                try? modelContext.save()
            }
            
            petStore.restoreSelectedPet(from: pets)
            
            if !hasSeenWelcome {
                showWelcome = true
                hasSeenWelcome = true
            }
            
            // Initial schedule of daily reminders for all existing pets
            if let settings = try? modelContext.fetch(FetchDescriptor<AppSettings>()).first {
                NotificationManager.shared.rescheduleDailyReminders(for: pets, settings: settings)
            }
            
            // Sync StoreKit Pro status to SwiftData (handles both purchase and refund)
            if let settings = try? modelContext.fetch(FetchDescriptor<AppSettings>()).first {
                let storeKitPro = IAPManager.shared.isPro
                if settings.isPro != storeKitPro {
                    settings.isPro = storeKitPro
                    try? modelContext.save()
                }
            }
        }
    }
}

//
//  MainTabView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
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
            // Background gradient for liquid glass effect
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Image(systemName: "sun.max.fill")
                        Text("今日")
                    }
                    .tag(0)
                
                ProfilesView()
                    .tabItem {
                        Image(systemName: "pawprint.fill")
                        Text("档案")
                    }
                    .tag(1)
                
                InsightsView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("统计")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("设置")
                    }
                    .tag(3)
            }
            .accentColor(.blue)
            
            // Floating Quick Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        petStore.showingQuickAdd = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(.blue)
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90) // Above tab bar
                }
            }
        }
        .sheet(isPresented: $petStore.showingQuickAdd) {
            QuickAddView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView(showWelcome: $showWelcome)
        }
        .onAppear {
            // Select first pet if available
            if petStore.selectedPet == nil && !pets.isEmpty {
                petStore.selectedPet = pets.first
            }
            
            // Show welcome if first time
            if !hasSeenWelcome {
                showWelcome = true
                hasSeenWelcome = true
            }
        }
    }
}
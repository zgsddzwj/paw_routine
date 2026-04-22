//
//  MainTabView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: TabItem = .today
    @State private var showQuickAdd = false
    @State private var showSettings = false
    
    enum TabItem: String, CaseIterable {
        case today = "今日"
        case profiles = "档案"
        case insights = "统计"
        case settings = "设置"
        
        var icon: String {
            switch self {
            case .today: return "sun.max.fill"
            case .profiles: return "pawprint.fill"
            case .insights: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 主内容区
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(TabItem.today)
                    .tabItem {
                        Label(TabItem.today.rawValue, systemImage: TabItem.today.icon)
                    }
                
                ProfilesView()
                    .tag(TabItem.profiles)
                    .tabItem {
                        Label(TabItem.profiles.rawValue, systemImage: TabItem.profiles.icon)
                    }
                
                InsightsView()
                    .tag(TabItem.insights)
                    .tabItem {
                        Label(TabItem.insights.rawValue, systemImage: TabItem.insights.icon)
                    }
                
                SettingsView()
                    .tag(TabItem.settings)
                    .tabItem {
                        Label(TabItem.settings.rawValue, systemImage: TabItem.settings.icon)
                    }
            }
            
            // 浮动 "+" 按钮（独立于 TabBar）
            Button {
                showQuickAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [PawRoutineTheme.Colors.primary, PawRoutineTheme.Colors.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: PawRoutineTheme.Colors.primary.opacity(0.4), radius: 12, y: 6)
                    )
            }
            .buttonStyle(PawRoutineTheme.FloatingButtonStyle())
            .padding(.trailing, 24)
            // 避开 TabBar 高度 + 安全区域
            .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet(isPresented: $showQuickAdd)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Pet.self, inMemory: true)
}

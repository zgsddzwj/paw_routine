//
//  MainTabView.swift
//  PawRoutine
//
//  主 Tab 视图 - 设计稿还原
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: TabItem = .today
    @State private var showQuickAdd = false
    
    enum TabItem: String, CaseIterable {
        case today = "今日"
        case profiles = "档案"
        case insights = "统计"
        case settings = "设置"
        
        var icon: String {
            switch self {
            case .today: return "house.fill"
            case .profiles: return "pawprint.fill"
            case .insights: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(TabItem.today)
                
                ProfilesView()
                    .tag(TabItem.profiles)
                
                InsightsView()
                    .tag(TabItem.insights)
                
                SettingsView()
                    .tag(TabItem.settings)
            }
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
            
            // 自定义底部 Tab 栏
            VStack(spacing: 0) {
                Divider()
                    .background(PawRoutineTheme.Colors.separator)
                
                HStack(spacing: 0) {
                    ForEach(TabItem.allCases, id: \.self) { tab in
                        tabButton(for: tab)
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 8)
                .background(
                    Color.white
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: -2)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet(isPresented: $showQuickAdd)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(PawRoutineTheme.Colors.bgPrimary)
        }
    }
    
    // MARK: - Tab Button
    
    private func tabButton(for tab: TabItem) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(selectedTab == tab ? PawRoutineTheme.Colors.primary : PawRoutineTheme.Colors.textTertiary)
                    .symbolEffect(.bounce, value: selectedTab == tab)
                
                Text(tab.rawValue)
                    .font(PawRoutineTheme.PRFont.micro(selectedTab == tab ? .semibold : .regular))
                    .foregroundStyle(selectedTab == tab ? PawRoutineTheme.Colors.primary : PawRoutineTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Pet.self, inMemory: true)
}

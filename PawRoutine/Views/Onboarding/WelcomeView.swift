//
//  WelcomeView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            icon: "pawprint.fill",
            title: "欢迎使用 PawRoutine",
            subtitle: "科学管理宠物的日常起居和健康档案",
            description: "帮助您记录、追踪和管理宠物的每一个重要时刻"
        ),
        OnboardingPage(
            icon: "clock.fill",
            title: "智能提醒",
            subtitle: "从此不再忘记重要时刻",
            description: "自动提醒喂食、遛狗、医疗检查等重要事项"
        ),
        OnboardingPage(
            icon: "chart.xyaxis.line",
            title: "数据统计",
            subtitle: "直观的趋势分析",
            description: "通过图表和统计了解宠物的健康状态和行为模式"
        ),
        OnboardingPage(
            icon: "icloud.fill",
            title: "云端同步",
            subtitle: "多设备无缝体验",
            description: "通过 iCloud 在所有设备间同步宠物数据"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Bottom Section
            VStack(spacing: 20) {
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? .blue : .gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button("上一步") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("下一步") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.blue, in: Capsule())
                    } else {
                        Button("开始使用") {
                            withAnimation {
                                showWelcome = false
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.blue, in: Capsule())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    WelcomeView(showWelcome: .constant(true))
}

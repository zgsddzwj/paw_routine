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
            title: NSLocalizedString("Welcome to PawRoutine", comment: ""),
            subtitle: NSLocalizedString("Scientifically manage your pet's daily life and health records", comment: ""),
            description: NSLocalizedString("Help you record, track and manage every important moment of your pet", comment: "")
        ),
        OnboardingPage(
            icon: "clock.fill",
            title: NSLocalizedString("Smart Reminders", comment: ""),
            subtitle: NSLocalizedString("Never forget important moments again", comment: ""),
            description: NSLocalizedString("Automatically remind you of feeding, walking, medical checkups and more", comment: "")
        ),
        OnboardingPage(
            icon: "chart.xyaxis.line",
            title: NSLocalizedString("Data Statistics", comment: ""),
            subtitle: NSLocalizedString("Intuitive trend analysis", comment: ""),
            description: NSLocalizedString("Understand your pet's health and behavior through charts and statistics", comment: "")
        ),
        OnboardingPage(
            icon: "icloud.fill",
            title: NSLocalizedString("Cloud Sync", comment: ""),
            subtitle: NSLocalizedString("Seamless multi-device experience", comment: ""),
            description: NSLocalizedString("Sync pet data across all devices via iCloud", comment: "")
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
                        Button(NSLocalizedString("Previous", comment: "")) {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(NSLocalizedString("Next", comment: "")) {
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
                        Button(NSLocalizedString("Get Started", comment: "")) {
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

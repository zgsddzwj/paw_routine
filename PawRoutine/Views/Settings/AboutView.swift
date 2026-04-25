//
//  AboutView.swift
//  PawRoutine
//
//  关于我们页面
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // App Icon
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
                                .frame(width: 100, height: 100)
                                .shadow(color: .orange.opacity(0.3), radius: 12, x: 0, y: 6)
                            
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text("FurryNote")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(String(format: NSLocalizedString("版本 %@ (%@)", comment: ""), appVersion, buildNumber))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Description
                    VStack(spacing: 12) {
                        Text("Pet Health & Daily Journal")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Scientific Care · Smart Reminders · Healthy Growth\n\nFurryNote helps you record your pet's daily activities, health status, and growth journey, ensuring every furry friend receives the best care.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 32)
                    
                    // Features
                    VStack(spacing: 16) {
                        FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "Quick Record", description: "One-tap recording of feeding, walking, water changes, and more")
                        FeatureRow(icon: "bell.fill", color: .orange, title: "Smart Reminders", description: "Timed reminders for important tasks, never forget again")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", color: .blue, title: "Data Analysis", description: "Health trends at a glance")
                        FeatureRow(icon: "icloud.fill", color: .cyan, title: "iCloud Sync", description: "Real-time data sync across devices")
                    }
                    .padding(.horizontal, 24)
                    
                    // Links
                    VStack(spacing: 0) {
                        LinkRow(icon: "globe", title: "Official Website", url: "https://zgsddzwj.github.io/paw_routine_page")
                        Divider().padding(.leading, 52)
                        LinkRow(icon: "envelope.fill", title: "Contact Us", url: "mailto:zgsddzwj@gmail.com")
                        Divider().padding(.leading, 52)
                        LinkRow(icon: "star.fill", title: "Rate & Review", url: "itms-apps://itunes.apple.com/app/id6763751025?action=write-review")
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    
                    // Copyright
                    Text("© 2026 FurryNote. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("About FurryNote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct LinkRow: View {
    let icon: String
    let title: LocalizedStringKey
    let url: String
    
    var body: some View {
        if let linkURL = URL(string: url) {
            Link(destination: linkURL) {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        } else {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

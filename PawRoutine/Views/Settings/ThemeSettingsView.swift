//
//  ThemeSettingsView.swift
//  PawRoutine
//
//  主题模式设置
//

import SwiftUI
import SwiftData

struct ThemeSettingsView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Button {
                            settings.themeMode = mode
                            try? modelContext.save()
                        } label: {
                            HStack {
                                Image(systemName: iconForMode(mode))
                                    .foregroundColor(.blue)
                                    .frame(width: 28)
                                
                                Text(mode.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if settings.themeMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Preview"), footer: Text("Choose 'System' to automatically switch between light and dark mode based on system settings.")) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentColorScheme == .dark ? Color.black : Color.white)
                            .frame(height: 120)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(Image(systemName: "pawprint.fill").foregroundColor(.blue))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(currentColorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.8))
                                        .frame(width: 80, height: 8)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(currentColorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                                        .frame(width: 50, height: 6)
                                }
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                ForEach(0..<3) { _ in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(height: 40)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(currentColorScheme == .dark ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Theme")
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
        .preferredColorScheme(colorScheme)
        }
    }
    
    private var currentColorScheme: ColorScheme {
        switch settings.themeMode {
        case .light: return .light
        case .dark: return .dark
        case .system: return systemColorScheme
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch settings.themeMode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    private func iconForMode(_ mode: ThemeMode) -> String {
        switch mode {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

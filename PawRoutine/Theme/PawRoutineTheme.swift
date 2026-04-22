//
//  PawRoutineTheme.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI

// MARK: - Liquid Glass Theme (iOS 26 Style)

struct PawRoutineTheme {
    // MARK: - Colors
    
    struct Colors {
        static let primary = Color(red: 0.35, green: 0.53, blue: 0.71)      // 钢蓝色
        static let primaryLight = Color(red: 0.55, green: 0.73, blue: 0.91)
        static let secondary = Color(red: 0.45, green: 0.72, blue: 0.62)    // 薄荷绿
        static let accent = Color.orange                                      // 活力橙
        
        // 功能色
        static let feeding = Color.orange
        static let water = Color.blue
        static let walking = Color.green
        static let medication = Color.red
        static let bathroom = Color.brown
        
        // 玻璃效果色
        static let glassBackground = Color.white.opacity(0.15)
        static let glassBorder = Color.white.opacity(0.3)
        static let glassShadow = Color.black.opacity(0.1)
        
        // 背景渐变
        static let gradientTop = Color(
            red: 0.90, green: 0.93, blue: 1.0
        )
        static let gradientBottom = Color(
            red: 0.95, green: 0.92, blue: 0.96
        )
    }
    
    // MARK: - Glass Material Modifier
    
    struct GlassModifier: ViewModifier {
        var cornerRadius: CGFloat = 20
        var padding: CGFloat = 16
        
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Colors.glassBorder, lineWidth: 0.5)
                        )
                        .shadow(color: Colors.glassShadow, radius: 10, x: 0, y: 4)
                )
        }
    }
    
    // MARK: - Floating Button Style
    
    struct FloatingButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 24, weight: .bold))
                .frame(width: 60, height: 60)
                .foregroundStyle(.white)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Colors.primary, Colors.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Colors.primary.opacity(0.4), radius: 12, y: 6)
                )
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
        }
    }
}

// MARK: - View Extensions

extension View {
    /// 应用液态玻璃卡片效果（作为修饰符）
    func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        modifier(PawRoutineTheme.GlassModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

/// 液态玻璃卡片容器（支持闭包语法: glassCard { ... }）
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: Content
    
    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(PawRoutineTheme.Colors.glassBorder, lineWidth: 0.5)
                    )
                    .shadow(color: PawRoutineTheme.Colors.glassShadow, radius: 10, x: 0, y: 4)
            )
    }
}

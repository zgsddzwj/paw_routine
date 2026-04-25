//
//  PawRoutineTheme.swift
//  PawRoutine
//
//  设计稿还原 - iOS 26 Liquid Glass 设计系统
//

import SwiftUI

// MARK: - Design System

struct PawRoutineTheme {
    
    // MARK: - Colors
    
    struct Colors {
        // 主色调
        static let primary = Color(red: 0.40, green: 0.55, blue: 0.95)
        static let primaryLight = Color(red: 0.65, green: 0.75, blue: 1.0)
        static let secondary = Color(red: 0.35, green: 0.78, blue: 0.58)
        static let accent = Color(red: 1.00, green: 0.58, blue: 0.00)
        
        // 功能色
        static let feeding = Color(red: 1.00, green: 0.58, blue: 0.00)
        static let water = Color(red: 0.33, green: 0.62, blue: 0.94)
        static let walking = Color(red: 0.35, green: 0.78, blue: 0.58)
        static let medication = Color(red: 0.96, green: 0.42, blue: 0.38)
        static let bathroom = Color(red: 0.60, green: 0.50, blue: 0.35)
        
        // 文字色
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(red: 0.55, green: 0.55, blue: 0.57)
        
        // 背景色
        static let bgPrimary = Color(.systemGroupedBackground)
        static let bgCard = Color(.secondarySystemGroupedBackground)
        static let bgSecondary = Color(red: 0.94, green: 0.94, blue: 0.96)
        
        // 分割线/边框
        static let separator = Color(.separator).opacity(0.6)
        static let border = Color(.separator).opacity(0.4)
    }
    
    // MARK: - Typography
    
    struct PRFont {
        static func largeTitle(_ weight: Font.Weight = .bold) -> SwiftUI.Font {
            .system(size: 32, weight: weight, design: .rounded)
        }
        static func title1(_ weight: Font.Weight = .bold) -> SwiftUI.Font {
            .system(size: 24, weight: weight, design: .rounded)
        }
        static func title2(_ weight: Font.Weight = .semibold) -> SwiftUI.Font {
            .system(size: 20, weight: weight, design: .rounded)
        }
        static func title3(_ weight: Font.Weight = .semibold) -> SwiftUI.Font {
            .system(size: 17, weight: weight, design: .rounded)
        }
        static func bodyText(_ weight: Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: 16, weight: weight, design: .rounded)
        }
        static func caption(_ weight: Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: 14, weight: weight, design: .rounded)
        }
        static func caption2(_ weight: Font.Weight = .medium) -> SwiftUI.Font {
            .system(size: 12, weight: weight, design: .rounded)
        }
        static func micro(_ weight: Font.Weight = .medium) -> SwiftUI.Font {
            .system(size: 10, weight: weight, design: .rounded)
        }
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let full: CGFloat = 9999
    }
    
    // MARK: - Shadows
    
    struct Shadows {
        static let card = ShadowStyle(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        static let small = ShadowStyle(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        static let button = ShadowStyle(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Extensions

extension View {
    func prCardStyle(cornerRadius: CGFloat = PawRoutineTheme.Radius.lg, bgColor: Color = PawRoutineTheme.Colors.bgCard) -> some View {
        self
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: PawRoutineTheme.Shadows.card.color,
                radius: PawRoutineTheme.Shadows.card.radius,
                x: PawRoutineTheme.Shadows.card.x,
                y: PawRoutineTheme.Shadows.card.y
            )
    }
    
    func prButtonScale() -> some View {
        self
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
    }
}

// MARK: - Card Component

struct PRCard<Content: View>: View {
    var cornerRadius: CGFloat = PawRoutineTheme.Radius.lg
    var paddingValue: CGFloat? = nil
    var paddingEdges: EdgeInsets? = nil
    var bgColor: Color = PawRoutineTheme.Colors.bgCard
    @ViewBuilder let content: Content
    
    init(
        cornerRadius: CGFloat = PawRoutineTheme.Radius.lg,
        padding: CGFloat = PawRoutineTheme.Spacing.lg,
        bgColor: Color = PawRoutineTheme.Colors.bgCard,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.paddingValue = padding
        self.paddingEdges = nil
        self.bgColor = bgColor
        self.content = content()
    }
    
    init(
        cornerRadius: CGFloat = PawRoutineTheme.Radius.lg,
        padding edges: EdgeInsets,
        bgColor: Color = PawRoutineTheme.Colors.bgCard,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.paddingValue = nil
        self.paddingEdges = edges
        self.bgColor = bgColor
        self.content = content()
    }
    
    var body: some View {
        let edges = paddingEdges ?? EdgeInsets(
            top: paddingValue ?? PawRoutineTheme.Spacing.lg,
            leading: paddingValue ?? PawRoutineTheme.Spacing.lg,
            bottom: paddingValue ?? PawRoutineTheme.Spacing.lg,
            trailing: paddingValue ?? PawRoutineTheme.Spacing.lg
        )
        return content
            .padding(edges)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: PawRoutineTheme.Shadows.card.color,
                radius: PawRoutineTheme.Shadows.card.radius,
                x: PawRoutineTheme.Shadows.card.x,
                y: PawRoutineTheme.Shadows.card.y
            )
    }
}

// MARK: - Section Header

struct PRSectionHeader: View {
    let title: LocalizedStringKey
    var trailing: AnyView? = nil
    
    init(_ title: LocalizedStringKey, @ViewBuilder trailing: () -> some View) {
        self.title = title
        self.trailing = AnyView(trailing())
    }
    
    init(_ title: LocalizedStringKey) {
        self.title = title
        self.trailing = nil
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(PawRoutineTheme.PRFont.title3(.bold))
                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
            
            Spacer()
            
            if let trailing {
                trailing
            }
        }
    }
}

// MARK: - Progress Ring

struct PRProgressRing: View {
    let progress: Double
    let total: Int
    let current: Int
    let color: Color
    let label: LocalizedStringKey
    var lineWidth: CGFloat = 8
    var size: CGFloat = 90
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.12), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedProgress)
            
            VStack(spacing: 2) {
                Text(label)
                    .font(PawRoutineTheme.PRFont.caption2(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                
                Text("\(current)/\(total)")
                    .font(PawRoutineTheme.PRFont.bodyText(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    .monospacedDigit()
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                animatedProgress = min(progress, 1.0)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}

// MARK: - Pet Avatar

struct PRPetAvatar: View {
    let image: Image?
    let size: CGFloat
    var isSelected: Bool = false
    var showBorder: Bool = false
    
    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: size / 2)
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
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: size * 0.35))
                            .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.4))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(isSelected ? PawRoutineTheme.Colors.secondary : Color.clear,
                       lineWidth: isSelected ? 3 : 0)
        )
        .overlay(alignment: .bottomTrailing) {
            if isSelected {
                Circle()
                    .fill(PawRoutineTheme.Colors.secondary)
                    .frame(width: size * 0.24, height: size * 0.24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: size * 0.12, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: 2, y: 2)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
            }
        }
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Tag/Badge

struct PRTag: View {
    let text: LocalizedStringKey
    var color: Color = PawRoutineTheme.Colors.primary
    
    var body: some View {
        Text(text)
            .font(PawRoutineTheme.PRFont.caption2(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Empty State

struct PREmptyState: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?
    
    init(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: PawRoutineTheme.Spacing.md) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
            
            Text(title)
                .font(PawRoutineTheme.PRFont.title3(.semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
            
            if let subtitle {
                Text(subtitle)
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PawRoutineTheme.Spacing.xxl)
            }
            
            Spacer()
        }
        .padding(.vertical, PawRoutineTheme.Spacing.xxxl)
    }
}

// MARK: - List Row Component

struct PRListRow<Leading: View, Trailing: View>: View {
    let leading: Leading
    let trailing: Trailing
    
    init(
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.leading = leading()
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            leading
            Spacer()
            trailing
        }
        .padding(.vertical, PawRoutineTheme.Spacing.md)
    }
}

// MARK: - Icon Container

struct PRIconContainer: View {
    let icon: String
    let color: Color
    let size: CGFloat
    
    init(icon: String, color: Color, size: CGFloat = 32) {
        self.icon = icon
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.sm, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Warm Background

struct PRWarmBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.98, blue: 0.95),
                Color(red: 1.00, green: 0.95, blue: 0.90)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

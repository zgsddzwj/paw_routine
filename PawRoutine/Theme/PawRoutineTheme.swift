//
//  PawRoutineTheme.swift
//  PawRoutine
//
//  设计稿还原 - 全新设计系统
//

import SwiftUI

// MARK: - Design System

struct PawRoutineTheme {
    
    // MARK: - Colors
    
    struct Colors {
        // 主色调
        static let primary = Color(red: 0.40, green: 0.55, blue: 0.95)       // 活力蓝
        static let primaryLight = Color(red: 0.65, green: 0.75, blue: 1.0)
        static let secondary = Color(red: 0.35, green: 0.78, blue: 0.58)     // 薄荷绿
        static let accent = Color(red: 1.00, green: 0.58, blue: 0.00)        // 活力橙
        
        // 功能色（匹配设计稿）
        static let feeding = Color(red: 1.00, green: 0.58, blue: 0.00)      // 橙色 - 喂食
        static let water = Color(red: 0.33, green: 0.62, blue: 0.94)         // 蓝色 - 换水
        static let walking = Color(red: 0.35, green: 0.78, blue: 0.58)       // 绿色 - 遛狗
        static let medication = Color(red: 0.96, green: 0.42, blue: 0.38)    // 红色 - 喂药
        static let bathroom = Color(red: 0.60, green: 0.50, blue: 0.35)      // 棕色 - 排便
        
        // 文字色
        static let textPrimary = Color(red: 0.12, green: 0.12, blue: 0.14)
        static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.48)
        static let textTertiary = Color(red: 0.70, green: 0.70, blue: 0.72)
        
        // 背景色
        static let bgPrimary = Color(red: 0.97, green: 0.97, blue: 0.98)
        static let bgCard = Color.white
        static let bgSecondary = Color(red: 0.94, green: 0.94, blue: 0.96)
        
        // 分割线/边框
        static let separator = Color(red: 0.90, green: 0.90, blue: 0.92)
        static let border = Color(red: 0.88, green: 0.88, blue: 0.90)
    }
    
    // MARK: - Typography
    
    struct Font {
        static func largeTitle(_ weight: Font.Weight = .bold) -> SwiftUI.Font {
            .system(size: 28, weight: weight, design: .rounded)
        }
        static func title1(_ weight: Font.Weight = .semibold) -> SwiftUI.Font {
            .system(size: 22, weight: weight, design: .rounded)
        }
        static func title2(_ weight: Font.Weight = .semibold) -> SwiftUI.Font {
            .system(size: 18, weight: weight, design: .rounded)
        }
        static func title3(_ weight: Font.Weight = .medium) -> SwiftUI.Font {
            .system(size: 16, weight: weight, design: .rounded)
        }
        static func bodyText(_ weight: Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: 15, weight: weight, design: .rounded)
        }
        static func caption(_ weight: Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: 13, weight: weight, design: .rounded)
        }
        static func caption2(_ weight: Font.Weight = .medium) -> SwiftUI.Font {
            .system(size: 11, weight: weight, design: .rounded)
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
}

// MARK: - Card Component (设计稿风格卡片)

struct PRCard<Content: View>: View {
    var cornerRadius: CGFloat = PawRoutineTheme.Radius.lg
    var padding: CGFloat = PawRoutineTheme.Spacing.lg
    var bgColor: Color = PawRoutineTheme.Colors.bgCard
    @ViewBuilder let content: Content
    
    init(
        cornerRadius: CGFloat = PawRoutineTheme.Radius.lg,
        padding: CGFloat = PawRoutineTheme.Spacing.lg,
        bgColor: Color = PawRoutineTheme.Colors.bgCard,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.bgColor = bgColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Section Header

struct PRSectionHeader: View {
    let title: String
    var trailing: AnyView? = nil
    
    init(_ title: String, @ViewBuilder trailing: () -> some View) {
        self.title = title
        self.trailing = AnyView(trailing())
    }
    
    init(_ title: String) {
        self.title = title
        self.trailing = nil
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(PawRoutineTheme.Font.title3(.semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
            
            Spacer()
            
            if let trailing {
                trailing
            }
        }
    }
}

// MARK: - Progress Ring (设计稿三环)

struct PRProgressRing: View {
    let progress: Double
    let total: Int
    let current: Int
    let color: Color
    let label: String
    var lineWidth: CGFloat = 7
    var size: CGFloat = 64
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // 背景环
            Circle()
                .stroke(color.opacity(0.12), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // 进度环
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.7), color, color.opacity(0.7)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedProgress)
            
            // 中间文字
            VStack(spacing: 2) {
                Text("\(current)/\(total)")
                    .font(PawRoutineTheme.Font.caption2(.bold))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text(label)
                    .font(PawRoutineTheme.Font.micro())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
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

// MARK: - Pet Avatar (圆形头像 + 在线状态点)

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
                // 默认占位
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
                .stroke(isSelected ? PawRoutineTheme.Colors.primary : Color.clear,
                       lineWidth: showBorder ? 2.5 : 0)
        )
        .overlay(alignment: .bottomTrailing) {
            if isSelected {
                Circle()
                    .fill(PawRoutineTheme.Colors.secondary)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: size * 0.11, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: 1, y: 1)
            }
        }
    }
}

// MARK: - Tag/Badge

struct PRTag: View {
    let text: String
    var color: Color = PawRoutineTheme.Colors.primary
    
    var body: some View {
        Text(text)
            .font(PawRoutineTheme.Font.caption2(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.10), in: Capsule())
    }
}

// MARK: - Empty State

struct PREmptyState: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: PawRoutineTheme.Spacing.md) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.25))
            
            Text(title)
                .font(PawRoutineTheme.Font.title3(.semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
            
            if let subtitle {
                Text(subtitle)
                    .font(PawRoutineTheme.Font.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, PawRoutineTheme.Spacing.xxl)
    }
}

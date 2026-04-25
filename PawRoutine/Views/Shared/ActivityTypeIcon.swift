//
//  ActivityTypeIcon.swift
//  PawRoutine
//
//  活动类型图标组件（支持自定义切图或 Emoji fallback）
//

import SwiftUI

struct ActivityTypeIcon: View {
    let type: ActivityType
    var size: CGFloat = 32
    
    var body: some View {
        if let assetName = type.iconAssetName,
           UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: type.systemImage)
                .font(.system(size: size * 0.85))
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                .frame(width: size, height: size)
        }
    }
}

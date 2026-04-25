//
//  DailyProgressRingsView.swift
//  PawRoutine
//

import SwiftUI

struct DailyProgressRingsView: View {
    let pet: Pet
    @EnvironmentObject private var petStore: PetStore
    @State private var showingTargetEdit = false
    
    @State private var feedingTarget = 3
    @State private var walkingTarget = 2
    @State private var waterTarget = 1
    
    private var feedingCount: Int { petStore.getActivityCount(for: pet, type: .feeding) }
    private var walkingCount: Int { petStore.getActivityCount(for: pet, type: .walking) }
    private var waterCount: Int { petStore.getActivityCount(for: pet, type: .waterChange) }
    
    private var overallCompletion: Double {
        let feedingPct = min(Double(feedingCount) / Double(feedingTarget), 1.0)
        let walkingPct = min(Double(walkingCount) / Double(walkingTarget), 1.0)
        let waterPct = min(Double(waterCount) / Double(waterTarget), 1.0)
        return (feedingPct + walkingPct + waterPct) / 3.0 * 100
    }
    
    var body: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.xl) {
                // Header
                HStack {
                    Text("Today's Progress")
                        .font(PawRoutineTheme.PRFont.title3(.bold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button("Edit") {
                        showingTargetEdit = true
                    }
                    .font(PawRoutineTheme.PRFont.caption(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
                
                // Progress Rings
                HStack(spacing: PawRoutineTheme.Spacing.xxl) {
                    ProgressRingView(
                        title: "Walking",
                        current: walkingCount,
                        target: walkingTarget,
                        color: PawRoutineTheme.Colors.walking
                    )
                    
                    ProgressRingView(
                        title: "Feeding",
                        current: feedingCount,
                        target: feedingTarget,
                        color: PawRoutineTheme.Colors.feeding
                    )
                    
                    ProgressRingView(
                        title: "Water Change",
                        current: waterCount,
                        target: waterTarget,
                        color: PawRoutineTheme.Colors.water
                    )
                }
                .frame(maxWidth: .infinity)
                
                // Completion summary
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(PawRoutineTheme.Colors.feeding)
                    
                    Text(String(format: NSLocalizedString("目标已完成 %d%%", comment: ""), Int(overallCompletion)))
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    if overallCompletion >= 100 {
                        Text("🎉")
                            .font(.system(size: 14))
                    }
                }
            }
        }
        .sheet(isPresented: $showingTargetEdit) {
            TargetEditView(
                feedingTarget: $feedingTarget,
                walkingTarget: $walkingTarget,
                waterTarget: $waterTarget
            )
        }
    }
}

struct ProgressRingView: View {
    let title: LocalizedStringKey
    let current: Int
    let target: Int
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    private var isComplete: Bool {
        current >= target
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.12), lineWidth: 10)
                    .frame(width: 90, height: 90)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(color)
                } else {
                    VStack(spacing: 2) {
                        Text("\(current)/\(target)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    }
                }
            }
            
            Text(title)
                .font(PawRoutineTheme.PRFont.caption(.medium))
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
        }
    }
}

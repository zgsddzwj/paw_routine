//
//  DailyProgressRingsView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI

struct DailyProgressRingsView: View {
    let pet: Pet
    @EnvironmentObject private var petStore: PetStore
    
    // Get activity counts for today
    private var feedingCount: Int { petStore.getActivityCount(for: pet, type: .feeding) }
    private var walkingCount: Int { petStore.getActivityCount(for: pet, type: .walking) }
    private var waterCount: Int { petStore.getActivityCount(for: pet, type: .waterChange) }
    
    // Targets
    private let feedingTarget = 2
    private let walkingTarget = 2
    private let waterTarget = 1
    
    // Overall completion percentage
    private var overallCompletion: Double {
        let feedingPct = min(Double(feedingCount) / Double(feedingTarget), 1.0)
        let walkingPct = min(Double(walkingCount) / Double(walkingTarget), 1.0)
        let waterPct = min(Double(waterCount) / Double(waterTarget), 1.0)
        return (feedingPct + walkingPct + waterPct) / 3.0 * 100
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日进度")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("编辑")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        // Could open target editing
                    }
            }
            
            HStack(spacing: 20) {
                // Feeding Ring
                ProgressRingView(
                    title: "喂食",
                    current: feedingCount,
                    target: feedingTarget,
                    color: .orange,
                    icon: "🍖"
                )
                
                // Walking Ring
                ProgressRingView(
                    title: "遛狗",
                    current: walkingCount,
                    target: walkingTarget,
                    color: .green,
                    icon: "🦮"
                )
                
                // Water Ring
                ProgressRingView(
                    title: "换水",
                    current: waterCount,
                    target: waterTarget,
                    color: .blue,
                    icon: "💧"
                )
            }
            
            // Completion summary text (NEW - matching design)
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text("目标已完成 \(Int(overallCompletion))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("🎉")
                    .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ProgressRingView: View {
    let title: String
    let current: Int
    let target: Int
    let color: Color
    let icon: String
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    private var isComplete: Bool {
        current >= target
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color.opacity(0.6), color]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                // Center content - count or checkmark
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                } else {
                    VStack(spacing: 0) {
                        Text(icon)
                            .font(.title3)
                        
                        Text("\(current)/\(target)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}

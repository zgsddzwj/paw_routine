//
//  QuickAddView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData

struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var petStore: PetStore
    @Query private var pets: [Pet]
    
    @State private var selectedActivityType: ActivityType?
    @State private var customTime = Date()
    @State private var notes = ""
    @State private var showingCustomTime = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("快速记录")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let pet = petStore.selectedPet {
                        Text("为 \(pet.name) 记录活动")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("请先选择宠物")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Activity Buttons - 3 column grid matching design
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
                    ForEach(ActivityType.allCases.filter { $0 != .other }, id: \.self) { activityType in
                        QuickAddIconButton(
                            activityType: activityType,
                            isSelected: selectedActivityType == activityType
                        ) {
                            // Quick add with current time
                            addActivity(type: activityType, timestamp: Date())
                        } onLongPress: {
                            // Show custom options (time + notes)
                            selectedActivityType = activityType
                            customTime = Date()
                            notes = ""
                            showingCustomTime = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Bottom hint text (matching design)
                Text("长按可修改时间或添加备注")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
                    .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCustomTime) {
            CustomActivityView(
                activityType: selectedActivityType ?? .feeding,
                customTime: $customTime,
                notes: $notes
            ) { type, time, notes in
                addActivity(type: type, timestamp: time, notes: notes)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func addActivity(type: ActivityType, timestamp: Date, notes: String? = nil) {
        guard let selectedPet = petStore.selectedPet else { return }
        
        let activity = Activity(type: type, timestamp: timestamp, notes: notes)
        activity.pet = selectedPet
        selectedPet.activities.append(activity)
        modelContext.insert(activity)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
}

// MARK: - Quick Add Icon Button (matching design - large icon + label below)
struct QuickAddIconButton: View {
    let activityType: ActivityType
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Large icon circle
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 64, height: 64)
                    
                    Text(activityType.icon)
                        .font(.system(size: 30))
                }
                .shadow(color: iconBackgroundColor.opacity(0.3), radius: 6, x: 0, y: 3)
                
                // Label
                Text(activityType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress()
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var iconBackgroundColor: Color {
        switch activityType {
        case .feeding:
            return Color(red: 1.0, green: 0.9, blue: 0.85) // Light orange/warm
        case .waterChange:
            return Color(red: 0.85, green: 0.93, blue: 1.0) // Light blue
        case .walking:
            return Color(red: 0.88, green: 0.96, blue: 0.88) // Light green
        case .medication:
            return Color(red: 0.92, green: 0.88, blue: 0.96) // Light purple
        case .defecation:
            return Color(red: 0.95, green: 0.92, blue: 0.85) // Light brown
        case .other:
            return Color(red: 0.90, green: 0.90, blue: 0.90) // Light gray
        }
    }
}

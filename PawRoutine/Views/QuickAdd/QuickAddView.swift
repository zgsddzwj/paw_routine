//
//  QuickAddView.swift
//  PawRoutine
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
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 2) {
                        Text("Quick Record")
                            .font(PawRoutineTheme.PRFont.title2(.bold))
                        
                        if let pet = petStore.selectedPet {
                            Text(String(format: NSLocalizedString("为 %@ 记录活动", comment: ""), pet.name))
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        } else {
                            Text("Please select a pet first")
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.feeding)
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // Activity Buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 24) {
                        ForEach(ActivityType.allCases.filter { $0 != .other }, id: \.self) { activityType in
                            QuickAddIconButton(
                                activityType: activityType,
                                isSelected: selectedActivityType == activityType
                            ) {
                                addActivity(type: activityType, timestamp: Date())
                            } onLongPress: {
                                selectedActivityType = activityType
                                customTime = Date()
                                notes = ""
                                showingCustomTime = true
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
}

struct QuickAddIconButton: View {
    let activityType: ActivityType
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .shadow(
                            color: Color.black.opacity(0.06),
                            radius: 12,
                            x: 0,
                            y: 4
                        )
                    
                    ActivityTypeIcon(type: activityType, size: 36)
                }
                
                Text(activityType.displayName)
                    .font(PawRoutineTheme.PRFont.caption(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
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
}

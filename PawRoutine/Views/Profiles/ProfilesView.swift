//
//  ProfilesView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import SwiftData

struct ProfilesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pet.sortOrder) private var pets: [Pet]
    
    @State private var selectedPet: Pet?
    @State private var showAddPet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if pets.isEmpty {
                    emptyState
                } else if let pet = selectedPet ?? pets.first {
                    ProfileDetailView(pet: pet)
                        .id(pet.id)
                }
            }
            .navigationTitle("宠物档案")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPet) {
            AddPetView()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.3))
            
            Text("还没有宠物档案")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text("点击右上角添加你的第一只宠物吧！")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            
            Button {
                showAddPet = true
            } label: {
                Label("添加宠物", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [PawRoutineTheme.Colors.primary, PawRoutineTheme.Colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProfilesView()
        .modelContainer(for: Pet.self, inMemory: true)
}

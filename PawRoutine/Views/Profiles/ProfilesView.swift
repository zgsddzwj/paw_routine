//
//  ProfilesView.swift
//  PawRoutine
//
//  宠物档案列表 - 设计稿还原
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
                    PREmptyState(
                        icon: "pawprint.circle.fill",
                        title: "还没有宠物档案",
                        subtitle: "点击右上角添加你的第一只宠物吧！"
                    )
                } else if let pet = selectedPet ?? pets.first {
                    ProfileDetailView(pet: pet)
                        .id(pet.id)
                }
            }
            .navigationTitle("宠物档案")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddPet = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPet) {
            AddPetView()
        }
    }
}

#Preview {
    ProfilesView()
        .modelContainer(for: Pet.self, inMemory: true)
}

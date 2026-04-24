//
//  TodayView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject private var petStore: PetStore
    @Query private var pets: [Pet]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Pet Selector
                    if !pets.isEmpty {
                        PetSelectorView(pets: pets)
                    }
                    
                    // Daily Progress Rings (with completion percentage)
                    if let selectedPet = petStore.selectedPet {
                        DailyProgressRingsView(pet: selectedPet)
                        
                        // Today's Timeline (with upcoming reminders)
                        TodayTimelineView(pet: selectedPet)
                    } else if pets.isEmpty {
                        EmptyPetView()
                    }
                    
                    Spacer(minLength: 100) // Space for floating button
                }
                .padding(.horizontal)
            }
            .navigationTitle("今日看板")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct PetSelectorView: View {
    let pets: [Pet]
    @EnvironmentObject private var petStore: PetStore
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(pets) { pet in
                    PetAvatarView(
                        pet: pet,
                        isSelected: petStore.selectedPet?.id == pet.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            petStore.selectPet(pet)
                        }
                    }
                }
                
                // Add pet button
                Button(action: { petStore.showingAddPet = true }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundColor(.blue.opacity(0.5))
                            )
                        
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PetAvatarView: View {
    let pet: Pet
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                
                if let imageData = pet.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            Text(pet.name)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .blue : .primary)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct EmptyPetView: View {
    @EnvironmentObject private var petStore: PetStore
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "pawprint")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("还没有宠物档案")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("点击下方档案页面添加您的第一只宠物")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("添加宠物") {
                petStore.showingAddPet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

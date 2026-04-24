//
//  ProfilesView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData

struct ProfilesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var petStore: PetStore
    @Query private var pets: [Pet]
    @State private var showingAddPet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if pets.isEmpty {
                        EmptyProfilesView()
                    } else {
                        ForEach(pets) { pet in
                            NavigationLink(destination: PetDetailView(pet: pet)) {
                                PetProfileCard(pet: pet)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Spacer(minLength: 100) // Space for floating button
                }
                .padding(.horizontal)
            }
            .navigationTitle("宠物档案")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddPet = true
                    }) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPet) {
            AddPetView()
        }
    }
}

struct PetProfileCard: View {
    let pet: Pet
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Pet Avatar
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 80, height: 80)
                    
                    if let imageData = pet.profileImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "pawprint.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                
                // Pet Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(pet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(pet.breed)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(pet.gender.rawValue)
                        Text("•")
                        Text(pet.isNeutered ? "已绝育" : "未绝育")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Age Info
                VStack(alignment: .trailing, spacing: 4) {
                    Text(pet.ageDescription)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("相当于人类")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(pet.ageInHumanYears))岁")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                StatItem(
                    title: "今日活动",
                    value: "\(pet.activities.filter { Calendar.current.isDateInToday($0.timestamp) }.count)"
                )
                
                StatItem(
                    title: "医疗记录",
                    value: "\(pet.medicalRecords.count)"
                )
                
                StatItem(
                    title: "体重记录",
                    value: "\(pet.weightRecords.count)"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmptyProfilesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "pawprint")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("还没有宠物档案")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("创建您的第一个宠物档案，开始记录它们的健康与成长")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}
//
//  AddPetView.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var petStore: PetStore
    
    @State private var name = ""
    @State private var breed = ""
    @State private var gender = Gender.male
    @State private var birthDate = Date()
    @State private var isNeutered = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !breed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo Section
                    VStack(spacing: 16) {
                        Text("宠物照片")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(.blue, lineWidth: 2)
                                    )
                                
                                if let profileImageData,
                                   let uiImage = UIImage(data: profileImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 112, height: 112)
                                        .clipShape(Circle())
                                } else {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.title)
                                            .foregroundColor(.blue)
                                        Text("添加照片")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Basic Info Section
                    VStack(spacing: 16) {
                        Text("基本信息")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            TextField("宠物姓名", text: $name)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("品种", text: $breed)
                                .textFieldStyle(.roundedBorder)
                            
                            Picker("性别", selection: $gender) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            DatePicker(
                                "出生日期",
                                selection: $birthDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            
                            Toggle("已绝育", isOn: $isNeutered)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("添加宠物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        savePet()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
    }
    
    private func savePet() {
        let pet = Pet(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            breed: breed.trimmingCharacters(in: .whitespacesAndNewlines),
            gender: gender,
            birthDate: birthDate,
            isNeutered: isNeutered
        )
        
        pet.profileImageData = profileImageData
        
        modelContext.insert(pet)
        
        // Set as selected pet if it's the first one
        if petStore.selectedPet == nil {
            petStore.selectedPet = pet
        }
        
        dismiss()
    }
}
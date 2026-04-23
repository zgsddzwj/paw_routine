//
//  EditPetView.swift
//  PawRoutine
//
//  编辑宠物 - 设计稿还原
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditPetView: View {
    @Bindable var pet: Pet
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("头像") { editPhotoPicker }
                
                Section("基本信息") {
                    TextField("宠物名字", text: $pet.name)
                        .textContentType(.name)
                    
                    TextField("品种", text: $pet.breed)
                    
                    Picker("类型", selection: $pet.petType) {
                        ForEach(PetType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    
                    Picker("性别", selection: $pet.gender) {
                        ForEach(Gender.allCases) { g in
                            Label(g.rawValue, systemImage: g.icon).tag(g)
                        }
                    }
                    
                    Toggle("已绝育", isOn: $pet.isNeutered)
                }
                
                Section("出生日期") {
                    DatePicker(
                        "生日",
                        selection: Binding(
                            get: { pet.birthDate ?? Date() },
                            set: { pet.birthDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("编辑 \(pet.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        pet.avatarData = data
                    }
                }
            }
        }
    }
    
    private var editPhotoPicker: some View {
        HStack {
            Spacer()
            
            if let avatarData = pet.avatarData, let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(PawRoutineTheme.Colors.bgSecondary)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: pet.petType.icon)
                            .font(.system(size: 32))
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    )
            }
            
            Spacer()
        }
        .overlay(alignment: .bottomTrailing) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "camera.fill")
                    .font(.title3)
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
            }
            .offset(x: -8, y: 8)
        }
    }
}

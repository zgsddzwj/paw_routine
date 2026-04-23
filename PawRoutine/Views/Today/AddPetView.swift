//
//  AddPetView.swift
//  PawRoutine
//
//  添加宠物 - 设计稿还原
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var breed = ""
    @State private var petType: PetType = .dog
    @State private var gender: Gender = .male
    @State private var isNeutered = false
    @State private var birthDate: Date?
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarData: Data?
    
    @Query(sort: \Pet.sortOrder) private var existingPets: [Pet]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("头像") { photoPicker }
                
                Section("基本信息") {
                    TextField("宠物名字", text: $name)
                        .textContentType(.name)
                    
                    TextField("品种（可选）", text: $breed)
                    
                    Picker("类型", selection: $petType) {
                        ForEach(PetType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("性别", selection: $gender) {
                        ForEach(Gender.allCases) { g in
                            Label(g.rawValue, systemImage: g.icon).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("已绝育", isOn: $isNeutered)
                }
                
                Section("出生日期") {
                    DatePicker(
                        "选择出生日期",
                        selection: Binding(
                            get: { birthDate ?? Date() },
                            set: { birthDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    
                    if let birthDate, !name.isEmpty {
                        agePreview(birthDate: birthDate)
                    }
                }
            }
            .navigationTitle("添加宠物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") { savePet() }
                        .fontWeight(.bold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        avatarData = data
                    }
                }
            }
        }
    }
    
    // MARK: - Photo Picker
    
    private var photoPicker: some View {
        HStack {
            Spacer()
            
            if let avatarData, let uiImage = UIImage(data: avatarData) {
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
                        VStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            Text("选择照片")
                                .font(PawRoutineTheme.Font.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        }
                    )
            }
            
            Spacer()
        }
        .overlay(alignment: .bottomTrailing) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
            }
            .offset(x: -8, y: 8)
        }
    }
    
    // MARK: - Age Preview
    
    private func agePreview(birthDate: Date) -> some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate, to: Date())
        
        // 粗略人类年龄估算
        let humanAge: Double?
        if let years = components.year, let months = components.month {
            if petType == .dog || petType == .cat {
                if years <= 1 {
                    humanAge = Double(years + months / 12) * 15.0
                } else if years <= 2 {
                    humanAge = 15.0 + Double(years - 1 + (months % 12) / 12) * 9.0
                } else {
                    humanAge = 24.0 + Double(years - 2 + (months % 12) / 12) * (petType == .dog ? 5.0 : 4.0)
                }
            } else {
                humanAge = Double(years + months / 12) * 7.0
            }
        } else {
            humanAge = nil
        }
        
        return HStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .foregroundStyle(PawRoutineTheme.Colors.secondary)
            
            if let years = components.year, let months = components.month, let days = components.day {
                VStack(alignment: .leading, spacing: 4) {
                    if years > 0 {
                        Text("约 \(years) 岁 \(months) 个月 (\(days) 天)")
                    } else if months > 0 {
                        Text("约 \(months) 个月 \(days) 天")
                    } else {
                        Text("\(days) 天大")
                    }

                    if let age = humanAge {
                        Text("≈ \(String(format: "%.1f", age)) 岁人类年龄")
                            .font(PawRoutineTheme.Font.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    }
                }
            }
        }
        .padding(8)
        .background(PawRoutineTheme.Colors.bgSecondary, in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.sm))
    }
    
    // MARK: - Save
    
    private func savePet() {
        let pet = Pet(
            name: name.trimmingCharacters(in: .whitespaces),
            breed: breed,
            petType: petType,
            gender: gender,
            isNeutered: isNeutered,
            birthDate: birthDate,
            avatarData: avatarData,
            sortOrder: existingPets.count
        )
        
        modelContext.insert(pet)
        dismiss()
    }
}

#Preview {
    AddPetView()
        .modelContainer(for: Pet.self, inMemory: true)
}

//
//  AddPetView.swift
//  PawRoutine
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
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawRoutineTheme.Spacing.xl) {
                        photoSection
                        basicInfoCard
                        genderSection
                        birthDateSection
                        neuteredSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                    .padding(.top, PawRoutineTheme.Spacing.lg)
                }
            }
            .navigationTitle("Add Pet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                saveButton
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
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack {
                if let profileImageData,
                   let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(PawRoutineTheme.Colors.separator, lineWidth: 1)
                        )
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    PawRoutineTheme.Colors.primary.opacity(0.15),
                                    PawRoutineTheme.Colors.secondary.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.5))
                        )
                        .overlay(
                            Circle()
                                .stroke(PawRoutineTheme.Colors.separator, lineWidth: 1)
                        )
                }
                
                // Edit badge
                Circle()
                    .fill(PawRoutineTheme.Colors.primary)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    )
                    .offset(x: 40, y: 40)
                    .shadow(color: PawRoutineTheme.Colors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PawRoutineTheme.Spacing.sm)
    }
    
    // MARK: - Basic Info Card
    
    private var basicInfoCard: some View {
        PRCard(padding: .init(top: 0, leading: 0, bottom: 0, trailing: 0)) {
            VStack(spacing: 0) {
                formRow(icon: "textformat", title: "Name") {
                    TextField("Enter pet name", text: $name)
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                        .multilineTextAlignment(.trailing)
                }
                
                Divider().padding(.leading, 52)
                
                formRow(icon: "pawprint", title: "Breed") {
                    TextField("Enter breed", text: $breed)
                        .font(PawRoutineTheme.PRFont.bodyText())
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    
    // MARK: - Gender Section
    
    private var genderSection: some View {
        VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.md) {
            Text("Gender")
                .font(PawRoutineTheme.PRFont.caption(.semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                .padding(.horizontal, PawRoutineTheme.Spacing.md)
            
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                ForEach(Gender.allCases, id: \.self) { g in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            gender = g
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: g == .male ? "mars" : "venus")
                                .font(.system(size: 16, weight: .semibold))
                            Text(g.displayName)
                                .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        }
                        .foregroundStyle(gender == g ? .white : PawRoutineTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            gender == g ? PawRoutineTheme.Colors.primary : Color.white,
                            in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                                .stroke(gender == g ? Color.clear : PawRoutineTheme.Colors.separator, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Birth Date Section
    
    private var birthDateSection: some View {
        PRCard(padding: .init(top: 0, leading: 0, bottom: 0, trailing: 0)) {
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                PRIconContainer(icon: "calendar", color: .orange, size: 28)
                
                Text("Birth Date")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: $birthDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.md)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Neutered Section
    
    private var neuteredSection: some View {
        PRCard(padding: .init(top: 0, leading: 0, bottom: 0, trailing: 0)) {
            HStack(spacing: PawRoutineTheme.Spacing.md) {
                PRIconContainer(icon: "checkmark.shield", color: .purple, size: 28)
                
                Text("Neutered")
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Spacer()
                
                Toggle("", isOn: $isNeutered)
                    .labelsHidden()
                    .tint(PawRoutineTheme.Colors.primary)
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.md)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(PawRoutineTheme.Colors.separator)
            
            Button {
                savePet()
            } label: {
                HStack {
                    Spacer()
                    Text("Save")
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                    Spacer()
                }
                .foregroundColor(.white)
                .frame(height: 50)
                .background(
                    canSave
                    ? PawRoutineTheme.Colors.primary
                    : PawRoutineTheme.Colors.primary.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                )
            }
            .disabled(!canSave)
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.vertical, PawRoutineTheme.Spacing.md)
        }
        .background(PRWarmBackground())
    }
    
    // MARK: - Helper
    
    private func formRow<Content: View>(
        icon: String,
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            PRIconContainer(icon: icon, color: PawRoutineTheme.Colors.primary, size: 28)
            
            Text(title)
                .font(PawRoutineTheme.PRFont.bodyText())
                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
            
            Spacer()
            
            content()
                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
        }
        .padding(.horizontal, PawRoutineTheme.Spacing.md)
        .padding(.vertical, 12)
    }
    
    // MARK: - Save
    
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
        petStore.selectPet(pet)
        
        // Schedule daily reminders for the new pet
        let settings = (try? modelContext.fetch(FetchDescriptor<AppSettings>()).first) ?? AppSettings()
        NotificationManager.shared.scheduleDailyReminders(for: pet, settings: settings)
        
        dismiss()
    }
}

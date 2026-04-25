//
//  PetDetailView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData

struct PetDetailView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var petStore: PetStore
    @State private var showEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: PawRoutineTheme.Spacing.xl) {
                    profileHeader
                    ageCard
                    functionMenu
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Delete Pet Profile")
                            Spacer()
                        }
                        .font(PawRoutineTheme.PRFont.bodyText(.medium))
                        .foregroundStyle(.red)
                        .padding(.vertical, 14)
                    }
                    .background(Color.red.opacity(0.06), in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
                    .padding(.top, PawRoutineTheme.Spacing.lg)
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.bottom, PawRoutineTheme.Spacing.xxxl)
            }
        }
        .navigationTitle("Pet Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            EditPetView(pet: pet)
        }
        .alert("Confirm Delete", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePet()
            }
        } message: {
            Text(String(format: NSLocalizedString("将删除 %@ 的所有数据，此操作无法撤销。", comment: ""), pet.name))
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        PRCard {
            HStack(spacing: PawRoutineTheme.Spacing.lg) {
                petAvatar
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(pet.name)
                            .font(PawRoutineTheme.PRFont.title1(.bold))
                        
                        Button { showEditSheet = true } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                                .padding(6)
                                .background(Circle().fill(PawRoutineTheme.Colors.bgSecondary))
                        }
                    }
                    
                    HStack(spacing: 6) {
                        if !pet.breed.isEmpty {
                            Text(pet.breed)
                                .font(PawRoutineTheme.PRFont.caption())
                                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                        }
                        
                        Text("·")
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        
                        Text(pet.gender.displayName)
                            .font(PawRoutineTheme.PRFont.caption())
                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    }
                    
                    if pet.isNeutered {
                        Text("Neutered")
                            .font(PawRoutineTheme.PRFont.caption2(.semibold))
                            .foregroundStyle(PawRoutineTheme.Colors.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(PawRoutineTheme.Colors.secondary.opacity(0.12), in: Capsule())
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private var petAvatar: some View {
        Group {
            if let imageData = pet.profileImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: 40)
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
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(PawRoutineTheme.Colors.primary.opacity(0.4))
                    )
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(PawRoutineTheme.Colors.separator, lineWidth: 1)
        )
    }
    
    // MARK: - Age Card
    
    private var ageCard: some View {
        PRCard(padding: .init(top: 20, leading: 20, bottom: 20, trailing: 20)) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Age")
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    Text(pet.ageDescription)
                        .font(PawRoutineTheme.PRFont.title1(.bold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    
                    Text(String(format: NSLocalizedString("≈ %.0f 岁（人类年龄）", comment: ""), pet.ageInHumanYears))
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Birth Date")
                        .font(PawRoutineTheme.PRFont.caption(.medium))
                        .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                    
                    Text(pet.birthDate, format: .dateTime.year().month().day())
                        .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Function Menu
    
    private var functionMenu: some View {
        PRCard(padding: .init(top: 4, leading: 16, bottom: 4, trailing: 16)) {
            VStack(spacing: 0) {
                NavigationLink(destination: MedicalRecordsView(pet: pet)) {
                    menuRow(
                        icon: "cross.case.fill",
                        iconColor: .blue,
                        title: "Medical Records",
                        subtitle: LocalizedStringKey(String(format: NSLocalizedString("%d 条记录", comment: ""), pet.medicalRecords.count))
                    )
                }
                .buttonStyle(.plain)
                
                Divider().padding(.leading, 44)
                
                NavigationLink(destination: WeightTrackingView(pet: pet)) {
                    let latestWeight = pet.weightRecords.sorted(by: { $0.date > $1.date }).first?.weight
                    let weightText = latestWeight != nil ? String(format: NSLocalizedString("最新 %.1f kg", comment: ""), latestWeight!) : NSLocalizedString("No records", comment: "")
                    menuRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .cyan,
                        title: "Weight Tracking",
                        subtitle: LocalizedStringKey(weightText)
                    )
                }
                .buttonStyle(.plain)
                
                Divider().padding(.leading, 44)
                
                NavigationLink(destination: DocumentsView(pet: pet)) {
                    menuRow(
                        icon: "folder.fill",
                        iconColor: .orange,
                        title: "Documents",
                        subtitle: LocalizedStringKey(String(format: NSLocalizedString("%d 个文件", comment: ""), pet.documents.count))
                    )
                }
                .buttonStyle(.plain)
                
                Divider().padding(.leading, 44)
                
                NavigationLink(destination: MemoView(pet: pet)) {
                    menuRow(
                        icon: "note.text",
                        iconColor: .green,
                        title: "Memos",
                        subtitle: "Record daily moments"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func menuRow(icon: String, iconColor: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        HStack(spacing: PawRoutineTheme.Spacing.md) {
            PRIconContainer(icon: icon, color: iconColor, size: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PawRoutineTheme.PRFont.bodyText(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                Text(subtitle)
                    .font(PawRoutineTheme.PRFont.caption())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    
    private func deletePet() {
        // Cancel all notifications for this pet
        NotificationManager.shared.removeAllNotifications(for: pet)
        
        if petStore.selectedPet?.id == pet.id {
            petStore.selectedPet = nil
        }
        modelContext.delete(pet)
        try? modelContext.save()
        dismiss()
    }
}

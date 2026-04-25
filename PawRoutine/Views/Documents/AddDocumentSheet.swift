//
//  AddDocumentSheet.swift
//  PawRoutine
//
//  添加证件 - 从 PawRoutine2 集成
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddDocumentSheet: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var documentType: DocumentType = .vaccineBook
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationStack {
            Form {
                Section("Photos") { documentPhotoPicker }
                
                Section("Info") {
                    TextField("Title (e.g. 2024 Vaccine Book)", text: $title)
                    
                    Picker("Document Type", selection: $documentType) {
                        ForEach(DocumentType.allCases) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
                              imageData != nil else { return }
                        
                        let doc = Document(
                            title: title.trimmingCharacters(in: .whitespaces),
                            documentType: documentType,
                            imageData: imageData
                        )
                        doc.pet = pet
                        modelContext.insert(doc)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || imageData == nil)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        }
    }
    
    private var documentPhotoPicker: some View {
        HStack {
            Spacer()
            
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
            } else {
                RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                    .foregroundStyle(PawRoutineTheme.Colors.border.opacity(0.6))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title)
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
                            Text("Tap to select photo")
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
                        }
                    )
            }
            
            Spacer()
        }
        .overlay(alignment: .bottomTrailing) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
            }
            .offset(x: -8, y: -8)
        }
    }
}

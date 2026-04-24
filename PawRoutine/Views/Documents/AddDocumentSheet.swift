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
        NavigationStack {
            Form {
                Section("照片") { documentPhotoPicker }
                
                Section("信息") {
                    TextField("标题（如：2024年疫苗本）", text: $title)
                    
                    Picker("证件类型", selection: $documentType) {
                        ForEach(DocumentType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("添加证件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
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
                            Text("点击选择照片")
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

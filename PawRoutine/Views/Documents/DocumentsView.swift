//
//  DocumentsView.swift
//  PawRoutine
//
//  证件夹 - 从 PawRoutine2 回滚
//

import SwiftUI
import SwiftData

struct DocumentsView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showAddDocument = false
    @State private var isEditing = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                if pet.documents.isEmpty {
                    PREmptyState(
                        icon: "folder.fill",
                        title: "还没有证件",
                        subtitle: "点击右上角或下方按钮添加证件照片"
                    )
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(pet.documents) { doc in
                            DocumentCard(document: doc, isEditing: isEditing) {
                                deleteDocument(doc)
                            }
                        }
                        
                        // 添加按钮
                        addButtonCard
                    }
                }
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
        .navigationTitle("证件夹")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !pet.documents.isEmpty {
                    Button(isEditing ? "完成" : "编辑") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                    .font(PawRoutineTheme.PRFont.bodyText(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddDocument = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(PawRoutineTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showAddDocument) {
            AddDocumentSheet(pet: pet)
        }
    }
    
    private var addButtonCard: some View {
        Button {
            showAddDocument = true
        } label: {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md)
                    .fill(PawRoutineTheme.Colors.bgSecondary)
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    )
                
                Text("添加证件")
                    .font(PawRoutineTheme.PRFont.caption())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func deleteDocument(_ doc: Document) {
        modelContext.delete(doc)
    }
}

// MARK: - Document Card

struct DocumentCard: View {
    let document: Document
    let isEditing: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let imageData = document.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md))
                } else {
                    RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.md)
                        .fill(PawRoutineTheme.Colors.bgSecondary)
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: document.documentType.icon)
                                .font(.title)
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                        )
                }
                
                if isEditing {
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .background(Circle().fill(.white))
                    }
                    .padding(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(document.title)
                    .font(PawRoutineTheme.PRFont.caption(.medium))
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                Text(document.createdAt, format: .dateTime.year().month().day())
                    .font(PawRoutineTheme.PRFont.caption2())
                    .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

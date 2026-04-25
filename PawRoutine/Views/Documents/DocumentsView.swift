//
//  DocumentsView.swift
//  PawRoutine
//

import SwiftUI
import SwiftData

struct DocumentsView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var showAddDocument = false
    @State private var isEditing = false
    @State private var selectedDocument: Document?
    @State private var showingDetail = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: PawRoutineTheme.Spacing.lg) {
                    if pet.documents.isEmpty {
                        PREmptyState(
                            icon: "folder.fill",
                            title: "No Documents Yet",
                            subtitle: "Tap the top-right or bottom button to add document photos"
                        )
                        .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(pet.documents) { doc in
                                DocumentCard(document: doc, isEditing: isEditing) {
                                    deleteDocument(doc)
                                }
                                .onTapGesture {
                                    if !isEditing {
                                        selectedDocument = doc
                                        showingDetail = true
                                    }
                                }
                            }
                            
                            addButtonCard
                        }
                    }
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.bottom, PawRoutineTheme.Spacing.xxxl)
            }
        }
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !pet.documents.isEmpty {
                    Button(isEditing ? "Done" : "Edit") {
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
        .sheet(isPresented: $showingDetail) {
            if let doc = selectedDocument {
                DocumentDetailView(document: doc, pet: pet)
            }
        }
    }
    
    private var addButtonCard: some View {
        Button {
            showAddDocument = true
        } label: {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                    .stroke(
                        PawRoutineTheme.Colors.primary.opacity(0.3),
                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                    )
                    .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
                    .background(PawRoutineTheme.Colors.bgCard, in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(PawRoutineTheme.Colors.primary)
                            Text("Add Document")
                                .font(PawRoutineTheme.PRFont.caption())
                                .foregroundStyle(PawRoutineTheme.Colors.primary)
                        }
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add Document")
                        .font(PawRoutineTheme.PRFont.caption())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    Text(" ")
                        .font(PawRoutineTheme.PRFont.caption2())
                        .foregroundStyle(Color.clear)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func deleteDocument(_ doc: Document) {
        modelContext.delete(doc)
    }
}

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
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
                        .background(PawRoutineTheme.Colors.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
                        .shadow(
                            color: PawRoutineTheme.Shadows.small.color,
                            radius: PawRoutineTheme.Shadows.small.radius,
                            x: PawRoutineTheme.Shadows.small.x,
                            y: PawRoutineTheme.Shadows.small.y
                        )
                } else {
                    RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous)
                        .fill(PawRoutineTheme.Colors.bgCard)
                        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
                        .overlay(
                            Image(systemName: document.documentType.icon)
                                .font(.system(size: 28))
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary.opacity(0.5))
                        )
                        .shadow(
                            color: PawRoutineTheme.Shadows.small.color,
                            radius: PawRoutineTheme.Shadows.small.radius,
                            x: PawRoutineTheme.Shadows.small.x,
                            y: PawRoutineTheme.Shadows.small.y
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

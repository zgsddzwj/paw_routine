//
//  DocumentDetailView.swift
//  PawRoutine
//
//  证件查看详情
//

import SwiftUI
import SwiftData

struct DocumentDetailView: View {
    let document: Document
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Document Image
                    if let imageData = document.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: document.documentType.icon)
                                .font(.system(size: 60))
                                .foregroundColor(.blue.opacity(0.5))
                            
                            Text("No document image")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    // Document Info
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Type")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: document.documentType.icon)
                                    .foregroundColor(.blue)
                                Text(document.documentType.displayName)
                                    .font(.body)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(document.title)
                                .font(.body)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Added On")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(document.createdAt, format: .dateTime.year().month().day().hour().minute())
                                .font(.body)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Pet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(pet.name)
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button {
                            showingShareSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Document")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Document Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Confirm Delete", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteDocument()
                }
            } message: {
                Text("This document will be permanently deleted and cannot be recovered.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let imageData = document.imageData {
                    ShareSheet(activityItems: [imageData])
                }
            }
        }
        }
    }
    
    private func deleteDocument() {
        if let index = pet.documents.firstIndex(where: { $0.id == document.id }) {
            pet.documents.remove(at: index)
        }
        modelContext.delete(document)
        try? modelContext.save()
        dismiss()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

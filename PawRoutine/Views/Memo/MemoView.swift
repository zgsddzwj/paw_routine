//
//  MemoView.swift
//  PawRoutine
//
//  备忘录
//

import SwiftUI
import SwiftData

struct MemoView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var newMemoText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: PawRoutineTheme.Spacing.lg) {
                    memoInputCard
                    memosList
                }
                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                .padding(.top, PawRoutineTheme.Spacing.sm)
                .padding(.bottom, PawRoutineTheme.Spacing.xxxl)
            }
        }
        .navigationTitle("Memos")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var memoInputCard: some View {
        PRCard(padding: .init(top: 16, leading: 16, bottom: 16, trailing: 16)) {
            VStack(spacing: PawRoutineTheme.Spacing.md) {
                TextField(String(format: NSLocalizedString("记录关于 %@ 的点滴...", comment: ""), pet.name), text: $newMemoText, axis: .vertical)
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .lineLimit(3...6)
                    .focused($isFocused)
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                
                HStack {
                    Spacer()
                    
                    Button {
                        addMemo()
                    } label: {
                        Text("Save")
                            .font(PawRoutineTheme.PRFont.caption(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(
                                newMemoText.isEmpty ? PawRoutineTheme.Colors.primary.opacity(0.4) : PawRoutineTheme.Colors.primary,
                                in: Capsule()
                            )
                    }
                    .disabled(newMemoText.isEmpty)
                }
            }
        }
    }
    
    private var memosList: some View {
        VStack(spacing: PawRoutineTheme.Spacing.lg) {
            let memos = pet.activities
                .filter { $0.type == .other && $0.notes != nil && !$0.notes!.isEmpty }
                .sorted { $0.timestamp > $1.timestamp }
            
            if memos.isEmpty && newMemoText.isEmpty {
                PREmptyState(
                    icon: "note.text",
                    title: "No notes yet",
                    subtitle: "Record daily moments about \(pet.name) in the input box above"
                )
                .padding(.top, 40)
            } else {
                ForEach(memos.prefix(10)) { record in
                    MemoCardRow(record: record) {
                        deleteMemo(record)
                    }
                }
            }
        }
    }
    
    private func deleteMemo(_ record: Activity) {
        if let index = pet.activities.firstIndex(where: { $0.id == record.id }) {
            pet.activities.remove(at: index)
        }
        modelContext.delete(record)
        try? modelContext.save()
    }
    
    private func addMemo() {
        let record = Activity(
            type: .other,
            timestamp: Date(),
            notes: newMemoText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        record.pet = pet
        modelContext.insert(record)
        newMemoText = ""
        isFocused = false
    }
}

// MARK: - Memo Card Row

struct MemoCardRow: View {
    let record: Activity
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: PawRoutineTheme.Spacing.sm) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(PawRoutineTheme.Colors.primary.opacity(0.5))
                .frame(width: 4)
                .padding(.vertical, 6)
            
            if let note = record.notes {
                PRCard(padding: .init(top: 14, leading: 14, bottom: 14, trailing: 14)) {
                    VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
                        Text(note)
                            .font(PawRoutineTheme.PRFont.bodyText())
                            .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                            .lineLimit(nil)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "note.text")
                                .font(.system(size: 12))
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            
                            Text(record.timestamp, format: .dateTime.year().month().day().hour().minute())
                                .font(PawRoutineTheme.PRFont.caption2())
                                .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

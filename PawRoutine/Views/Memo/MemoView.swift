//
//  MemoView.swift
//  PawRoutine
//
//  备忘录 - 从 PawRoutine2 回滚，适配 Activity 模型
//

import SwiftUI
import SwiftData

struct MemoView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var newMemoText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PawRoutineTheme.Spacing.lg) {
                // 添加备忘录输入框
                memoInputCard
                
                // 备忘录列表
                memosList
            }
            .padding(.horizontal, PawRoutineTheme.Spacing.lg)
            .padding(.bottom, PawRoutineTheme.Spacing.xxl)
        }
        .background(PawRoutineTheme.Colors.bgPrimary.ignoresSafeArea())
        .navigationTitle("备忘录")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var memoInputCard: some View {
        PRCard {
            VStack(spacing: PawRoutineTheme.Spacing.md) {
                TextField("记录关于 \(pet.name) 的点滴...", text: $newMemoText, axis: .vertical)
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .lineLimit(3...6)
                    .focused($isFocused)
                
                HStack {
                    Spacer()
                    
                    Button {
                        addMemo()
                    } label: {
                        Text("保存")
                            .font(PawRoutineTheme.PRFont.caption(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
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
                    title: "还没有备忘录",
                    subtitle: "在上面输入框记录关于 \(pet.name) 的日常点滴"
                )
                .padding(.top, 40)
            } else {
                ForEach(memos.prefix(10)) { record in
                    if let note = record.notes {
                        MemoCard(
                            content: note,
                            date: record.timestamp,
                            type: record.type
                        )
                    }
                }
            }
        }
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

// MARK: - Memo Card

struct MemoCard: View {
    let content: String
    let date: Date
    let type: ActivityType
    
    var body: some View {
        PRCard {
            VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
                Text(content)
                    .font(PawRoutineTheme.PRFont.bodyText())
                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                    .lineLimit(nil)
                
                HStack {
                    Text(type.icon)
                        .font(.caption)
                    
                    Text(date, format: .dateTime.year().month().day().hour().minute())
                        .font(PawRoutineTheme.PRFont.caption2())
                        .foregroundStyle(PawRoutineTheme.Colors.textTertiary)
                    
                    Spacer()
                }
            }
        }
    }
}

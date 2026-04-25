//
//  TargetEditView.swift
//  PawRoutine
//
//  每日目标编辑
//

import SwiftUI

struct TargetEditView: View {
    @Binding var feedingTarget: Int
    @Binding var walkingTarget: Int
    @Binding var waterTarget: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            PRWarmBackground().ignoresSafeArea()
            NavigationView {
                Form {
                    Section(header: Text("Daily Goal Count"), footer: Text("After setting, today's progress rings will be calculated with the new goal.")) {
                    Stepper(String(format: NSLocalizedString("喂食：%d 次", comment: ""), feedingTarget), value: $feedingTarget, in: 1...10)
                    Stepper(String(format: NSLocalizedString("遛狗：%d 次", comment: ""), walkingTarget), value: $walkingTarget, in: 1...10)
                    Stepper(String(format: NSLocalizedString("换水：%d 次", comment: ""), waterTarget), value: $waterTarget, in: 1...10)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        }
    }
}

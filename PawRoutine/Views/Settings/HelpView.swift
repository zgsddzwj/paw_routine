//
//  HelpView.swift
//  PawRoutine
//
//  帮助与反馈页面（本地）
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var faqs: [(question: String, answer: String)] {
        [
            (NSLocalizedString("How do I add a pet?", comment: ""), NSLocalizedString("Tap the + button next to the pet avatar bar on the \"Today\" page, or tap the Add Pet button on the \"Pets\" page. Fill in name, breed, gender, birth date, etc., then save.", comment: "")),
            (NSLocalizedString("How do I record daily activities?", comment: ""), NSLocalizedString("Tap the floating + button at the bottom right of the home screen, select an activity type (feeding, walking, water change, etc.) to record quickly. Long-press the icon to edit the time or add notes.", comment: "")),
            (NSLocalizedString("Why aren't reminder notifications working?", comment: ""), NSLocalizedString("Make sure you have allowed FurryNote to send notifications in system settings. Also check that the corresponding reminder switch is turned on in Settings → Default Reminders. After adding a new pet, the system will automatically register notifications based on your current reminder settings.", comment: "")),
            (NSLocalizedString("How do I export data?", comment: ""), NSLocalizedString("Go to \"Settings → Data Export (CSV)\", select the pet(s) to export (or all pets), tap \"Start Export\" to generate a CSV file for easy sharing with your vet.", comment: "")),
            (NSLocalizedString("What's the difference in Pro?", comment: ""), NSLocalizedString("Pro unlocks unlimited pets, advanced charts, data export (CSV), custom reminders, and priority support. One-time purchase, forever use.", comment: "")),
            (NSLocalizedString("How do I delete a pet or record?", comment: ""), NSLocalizedString("Go to the pet details from the \"Pets\" page and tap the red \"Delete Pet Profile\" button at the bottom to delete the pet and all related records. Medical records, weight records, etc. can be deleted by swiping left or long-pressing in their respective lists.", comment: ""))
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PRWarmBackground().ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawRoutineTheme.Spacing.xl) {
                        // Header
                        VStack(spacing: PawRoutineTheme.Spacing.md) {
                            ZStack {
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
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(PawRoutineTheme.Colors.primary)
                            }
                            
                            Text("Help & Feedback")
                                .font(PawRoutineTheme.PRFont.title2(.bold))
                            
                            Text("Here are answers to common questions. If you have other questions, feel free to contact us via email.")
                                .font(PawRoutineTheme.PRFont.bodyText())
                                .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                        }
                        .padding(.top, PawRoutineTheme.Spacing.lg)
                        
                        // FAQ List
                        VStack(spacing: PawRoutineTheme.Spacing.lg) {
                            ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                                PRCard(padding: .init(top: 16, leading: 16, bottom: 16, trailing: 16)) {
                                    VStack(alignment: .leading, spacing: PawRoutineTheme.Spacing.sm) {
                                        HStack(spacing: PawRoutineTheme.Spacing.sm) {
                                            Text("\(index + 1)")
                                                .font(PawRoutineTheme.PRFont.caption2(.bold))
                                                .foregroundStyle(.white)
                                                .frame(width: 22, height: 22)
                                                .background(PawRoutineTheme.Colors.primary, in: Circle())
                                            
                                            Text(faq.question)
                                                .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                                                .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                        }
                                        
                                        Text(faq.answer)
                                            .font(PawRoutineTheme.PRFont.bodyText())
                                            .foregroundStyle(PawRoutineTheme.Colors.textSecondary)
                                            .lineSpacing(3)
                                    }
                                }
                            }
                        }
                        
                        // Contact
                        PRCard(padding: .init(top: 16, leading: 16, bottom: 16, trailing: 16)) {
                            VStack(spacing: PawRoutineTheme.Spacing.md) {
                                Text("Still have questions?")
                                    .font(PawRoutineTheme.PRFont.bodyText(.semibold))
                                    .foregroundStyle(PawRoutineTheme.Colors.textPrimary)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 14))
                                    Text("zgsddzwj@gmail.com")
                                        .font(PawRoutineTheme.PRFont.bodyText(.medium))
                                }
                                .foregroundStyle(.white)
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(PawRoutineTheme.Colors.primary, in: RoundedRectangle(cornerRadius: PawRoutineTheme.Radius.lg, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if let url = URL(string: "mailto:zgsddzwj@gmail.com") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, PawRoutineTheme.Spacing.lg)
                }
            }
            .navigationTitle("Help & Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

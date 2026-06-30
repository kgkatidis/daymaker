// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct JournalEntryView: View {
    @EnvironmentObject var profileService: ProfileService
    @Environment(\.dismiss) var dismiss
    let compliment: Compliment
    @State private var note: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    complimentPreview
                    journalInput
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Σημείωμα")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Ακύρωση") { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Αποθήκευση") { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                note = compliment.journalNote ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
        }
    }

    private var complimentPreview: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.purple)
                .frame(width: 3)

            Text(compliment.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }

    private var journalInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Πώς σε έκανε να νιώσεις;")
                .font(.subheadline.bold())

            ZStack(alignment: .topLeading) {
                TextEditor(text: $note)
                    .frame(minHeight: 150)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .font(.body)
                    .lineSpacing(4)

                if note.isEmpty {
                    Text("Γράψε ό,τι νιώθεις...")
                        .foregroundColor(.secondary.opacity(0.6))
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )

            Text("Αυτές οι σημειώσεις είναι ιδιωτικές και αποθηκεύονται μόνο στη συσκευή σου.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func save() {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        profileService.saveJournalNote(for: compliment.id, note: trimmed)
        HapticService.success()
        dismiss()
    }
}

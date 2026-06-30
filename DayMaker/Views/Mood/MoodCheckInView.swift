// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct MoodCheckInView: View {
    @EnvironmentObject var profileService: ProfileService
    @State private var selected: MoodState? = nil
    @State private var appeared = false
    let onDone: (MoodState) -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Πώς νιώθεις σήμερα;")
                    .font(.headline)
                Text("Θα προσαρμόσω το μήνυμά σου αναλόγως.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)

            HStack(spacing: 12) {
                ForEach(MoodState.allCases, id: \.rawValue) { mood in
                    MoodButton(mood: mood, isSelected: selected == mood) {
                        HapticService.selection()
                        withAnimation(.spring(response: 0.3)) {
                            selected = mood
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            profileService.saveTodayMood(mood)
                            HapticService.success()
                            onDone(mood)
                        }
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}

struct MoodButton: View {
    let mood: MoodState
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: isSelected ? 34 : 28))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                Text(mood.label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(isSelected ? .purple : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.12) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

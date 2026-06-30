// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct StreakBannerView: View {
    @ObservedObject var streak = StreakService.shared
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(streak.streakEmoji)
                        .font(.title3)
                    Text("\(streak.currentStreak)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(streak.currentStreak == 1 ? "μέρα" : "μέρες")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                Text(streak.streakMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(streak.totalDays)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                Text("σύνολο")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .scaleEffect(appeared ? 1 : 0.97)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { appeared = true }
        }
    }
}

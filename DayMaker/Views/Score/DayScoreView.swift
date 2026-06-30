// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct DayScoreView: View {
    @ObservedObject var score = ScoreService.shared
    @State private var animatedProgress: Double = 0
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.12), lineWidth: 6)
                    .frame(width: 70, height: 70)

                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.2, dampingFraction: 0.7), value: animatedProgress)

                VStack(spacing: 0) {
                    Text("\(score.todayScore)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                    Text("/100")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Σκορ σήμερα")
                    .font(.subheadline.bold())
                VStack(alignment: .leading, spacing: 4) {
                    scoreRow(label: "Mood check-in", done: score.breakdown.moodChecked, pts: 20)
                    scoreRow(label: "Streak ενεργό", done: score.breakdown.streakActive, pts: 20)
                    scoreRow(label: "Μηνύματα διαβάστηκαν", done: score.breakdown.complimentsRead > 0, pts: score.breakdown.complimentsRead * 10)
                    scoreRow(label: "Journal σημείωση", done: score.breakdown.journalWritten, pts: 20)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .onAppear {
            score.recalculate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animatedProgress = score.breakdown.progress
            }
        }
        .onChange(of: score.todayScore) { _ in
            animatedProgress = score.breakdown.progress
        }
    }

    private var scoreColor: Color {
        switch score.todayScore {
        case 0..<30: return .red
        case 30..<60: return .orange
        case 60..<90: return .blue
        default: return .green
        }
    }

    private func scoreRow(label: String, done: Bool, pts: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 11))
                .foregroundColor(done ? .green : Color(UIColor.tertiaryLabel))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(done ? .primary : .secondary)
            Spacer()
            Text("+\(pts)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(done ? .green : Color(UIColor.tertiaryLabel))
        }
    }
}

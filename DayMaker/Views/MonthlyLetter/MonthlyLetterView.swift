// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct MonthlyLetterView: View {
    let compliment: Compliment
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var voice = VoiceService.shared
    @State private var appeared = false

    private static let monthNames = ["Ιανουαρίου","Φεβρουαρίου","Μαρτίου","Απριλίου",
                                      "Μαΐου","Ιουνίου","Ιουλίου","Αυγούστου",
                                      "Σεπτεμβρίου","Οκτωβρίου","Νοεμβρίου","Δεκεμβρίου"]

    private var monthName: String {
        let m = Calendar.current.component(.month, from: compliment.date)
        return MonthlyLetterView.monthNames[max(0, m - 1)]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ParticleBackground()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        titleBlock
                        letterBlock
                        actionButtons
                        signatureBlock
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 50)
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var titleBlock: some View {
        VStack(spacing: 14) {
            Text("🗓️")
                .font(.system(size: 56))
                .scaleEffect(appeared ? 1 : 0.4)
                .opacity(appeared ? 1 : 0)

            Text("Επιστολή \(monthName)")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .opacity(appeared ? 1 : 0)

            Text("Μια στιγμή για να δεις πόσο έχεις αναπτυχθεί")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
        }
        .padding(.top, 24)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.15)) {
                appeared = true
            }
        }
    }

    private var letterBlock: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            TypewriterText(
                fullText: compliment.text,
                font: .system(.body, design: .serif),
                color: .white.opacity(0.9),
                lineSpacing: 8,
                delay: 0.5
            )
            .multilineTextAlignment(.leading)
            .padding(24)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut.delay(0.5), value: appeared)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { VoiceService.shared.speak(compliment.text) }) {
                Label(voice.isSpeaking ? "Σταμάτα" : "Άκουσέ το",
                      systemImage: voice.isSpeaking ? "stop.fill" : "play.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(14)
            }

            ShareLink(item: compliment.text, message: Text("— DayMaker Επιστολή \(monthName)")) {
                Label("Κοινοποίηση", systemImage: "square.and.arrow.up")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(14)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut.delay(0.7), value: appeared)
    }

    private var signatureBlock: some View {
        VStack(spacing: 6) {
            Divider().background(Color.white.opacity(0.15))
            Text("— DayMaker · Επιστολή \(monthName)")
                .font(.system(.caption, design: .serif))
                .foregroundColor(.white.opacity(0.35))
                .italic()
            Text("© 2026 Konstantinos Gkatidis")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.2))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut.delay(0.8), value: appeared)
    }
}

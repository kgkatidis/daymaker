// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct SoulLetterView: View {
    let compliment: Compliment
    @Environment(\.dismiss) var dismiss
    @State private var appeared = false
    @ObservedObject private var voice = VoiceService.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                ScrollView {
                    VStack(spacing: 32) {
                        titleSection
                        letterText
                        actionButtons
                        signatureSection
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
            Text(compliment.date, format: .dateTime.weekday(.wide).day().month())
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("✉️")
                .font(.system(size: 52))
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)

            Text("Soul Letter")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .opacity(appeared ? 1 : 0)

            Text("Το εβδομαδιαίο σου γράμμα")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .opacity(appeared ? 1 : 0)
        }
        .padding(.top, 20)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                appeared = true
            }
        }
    }

    private var letterText: some View {
        Text(compliment.text)
            .font(.system(.body, design: .serif))
            .foregroundColor(.white.opacity(0.92))
            .lineSpacing(8)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { VoiceService.shared.speak(compliment.text) }) {
                HStack(spacing: 6) {
                    Image(systemName: voice.isSpeaking ? "stop.fill" : "play.fill")
                    Text(voice.isSpeaking ? "Σταμάτα" : "Άκουσέ το")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.15))
                .cornerRadius(25)
            }

            ShareLink(
                item: compliment.text,
                message: Text("— DayMaker Soul Letter")
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Κοινοποίηση")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.15))
                .cornerRadius(25)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut.delay(0.6), value: appeared)
    }

    private var signatureSection: some View {
        VStack(spacing: 6) {
            Divider()
                .background(Color.white.opacity(0.2))
            Text("— DayMaker")
                .font(.system(.caption, design: .serif))
                .foregroundColor(.white.opacity(0.4))
                .italic()
            Text("© 2026 Konstantinos Gkatidis")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.25))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut.delay(0.7), value: appeared)
    }
}

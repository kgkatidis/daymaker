// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct SurpriseBoostView: View {
    @EnvironmentObject var profileService: ProfileService
    @Environment(\.dismiss) var dismiss
    @StateObject private var boost = BoostService.shared
    @ObservedObject private var voice = VoiceService.shared

    @State private var complimentText: String? = nil
    @State private var isLoading = false
    @State private var appeared = false
    @State private var pulseRing = false
    @State private var showJournal = false
    @State private var generatedCompliment: Compliment? = nil

    var body: some View {
        ZStack {
            boostGradient.ignoresSafeArea()
            ParticleBackground()

            VStack(spacing: 0) {
                closeBar
                Spacer()
                content
                Spacer()
                bottomActions
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                appeared = true
            }
            generate()
        }
        .sheet(isPresented: $showJournal) {
            if let c = generatedCompliment {
                JournalEntryView(compliment: c)
                    .environmentObject(profileService)
            }
        }
    }

    private var boostGradient: some View {
        LinearGradient(
            colors: [Color(hex: "4776E6"), Color(hex: "8E54E9")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var closeBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(10)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 6) {
                ForEach(0..<BoostService.shared.maxPerDay, id: \.self) { i in
                    Circle()
                        .fill(i < boost.boostsUsedToday ? Color.white.opacity(0.35) : Color.white)
                        .frame(width: 7, height: 7)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var content: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .frame(width: 110, height: 110)
                    .scaleEffect(pulseRing ? 1.4 : 1.0)
                    .opacity(pulseRing ? 0 : 0.6)

                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 90, height: 90)

                Text("⚡️")
                    .font(.system(size: 44))
                    .scaleEffect(appeared ? 1 : 0.3)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    pulseRing = true
                }
            }

            VStack(spacing: 12) {
                Text("Instant Boost")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView().tint(.white)
                        Text("Ετοιμάζω κάτι ξεχωριστό...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                    }
                } else if let text = complimentText {
                    TypewriterText(
                        fullText: text,
                        font: .body,
                        color: .white,
                        lineSpacing: 6
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
    }

    private var bottomActions: some View {
        VStack(spacing: 14) {
            if complimentText != nil {
                HStack(spacing: 12) {
                    boostActionButton(icon: voice.isSpeaking ? "stop.fill" : "speaker.wave.2.fill",
                                      label: voice.isSpeaking ? "Σταμάτα" : "Άκουσέ το") {
                        if let text = complimentText { VoiceService.shared.speak(text) }
                    }

                    if let c = generatedCompliment {
                        ShareLink(item: c.text, message: Text("— DayMaker Instant Boost")) {
                            VStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                Text("Κοινοποίηση")
                                    .font(.caption.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(14)
                        }

                        boostActionButton(icon: "pencil", label: "Σημείωση") {
                            showJournal = true
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            if boost.remaining > 0 && complimentText != nil {
                Button(action: generate) {
                    Text("Άλλο ένα (\(boost.remaining) απομένουν)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 4)
            } else if boost.remaining == 0 && complimentText != nil {
                Text("Έφτασες το όριο για σήμερα. Τα βλέπεις αύριο! 🌅")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Button(action: { dismiss() }) {
                Text("Κλείσιμο")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .opacity(appeared ? 1 : 0)
    }

    private func boostActionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 18))
                Text(label).font(.caption.bold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.12))
            .cornerRadius(14)
        }
    }

    private func generate() {
        guard boost.canBoost else { return }
        isLoading = true
        complimentText = nil
        boost.useBoost()
        HapticService.impact(.heavy)

        Task {
            do {
                let system = """
                You are someone who deeply knows and loves this person. They need an emotional boost RIGHT NOW. \
                Give them one powerful, immediate, deeply personal compliment that cuts straight to their worth. \
                Make it feel urgent, real, and loving — like a best friend who sees exactly who they are. \
                2-3 sentences max. No generic phrases. Use their name. Language: match the profile (Greek or English).
                """
                let user = "The person who needs a boost right now:\n\n\(profileService.profile.summaryForAI)"

                let text = try await ClaudeService.shared.callBoost(system: system, user: user)
                let c = Compliment(text: text, slot: .morning, mood: profileService.todayMood, isSoulLetter: false)
                await MainActor.run {
                    complimentText = text
                    generatedCompliment = c
                    profileService.saveCompliment(c)
                    isLoading = false
                    HapticService.success()
                }
            } catch {
                await MainActor.run {
                    let name = profileService.profile.name.isEmpty ? "φίλε" : profileService.profile.name
                    complimentText = "\(name), αυτή τη στιγμή — ακριβώς τώρα — να ξέρεις ότι αξίζεις. Όχι αύριο, όχι όταν τελειώσεις κάτι. Τώρα, ακριβώς όπως είσαι."
                    isLoading = false
                }
            }
        }
    }
}

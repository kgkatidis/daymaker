// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct ComplimentCard: View {
    @EnvironmentObject var profileService: ProfileService
    let compliment: Compliment
    var compact: Bool = false
    var isNew: Bool = false

    @State private var appeared = false
    @State private var showShare = false
    @State private var showJournal = false
    @State private var isFav: Bool = false
    @ObservedObject private var voice = VoiceService.shared

    var body: some View {
        ZStack {
            DayMakerGradient(slot: (compliment.isSoulLetter || compliment.isMonthlyLetter) ? nil : compliment.slot)

            VStack(alignment: .leading, spacing: 12) {
                topBar
                textContent
                if !compact { actionBar }
            }
            .padding(compact ? 14 : 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: compact ? 14 : 20))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .scaleEffect(appeared ? 1 : 0.96)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            isFav = compliment.isFavorite
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { appeared = true }
        }
        .contextMenu {
            Button(action: { toggleFavorite() }) {
                Label(isFav ? "Αφαίρεση από Vault" : "Αποθήκευση στο Vault",
                      systemImage: isFav ? "heart.slash.fill" : "heart.fill")
            }
            Button(action: { showShare = true }) {
                Label("Κοινοποίηση", systemImage: "square.and.arrow.up")
            }
            Button(action: { VoiceService.shared.speak(compliment.text) }) {
                Label("Άκουσέ το", systemImage: "speaker.wave.2.fill")
            }
        }
        .sheet(isPresented: $showShare) { ShareCardView(compliment: compliment) }
        .sheet(isPresented: $showJournal) {
            JournalEntryView(compliment: compliment).environmentObject(profileService)
        }
    }

    private var topBar: some View {
        HStack(spacing: 6) {
            if compliment.isMonthlyLetter {
                Label("Μηνιαία Επιστολή", systemImage: "calendar.badge.clock")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.2)).cornerRadius(20)
            } else if compliment.isSoulLetter {
                Label("Soul Letter", systemImage: "envelope.open.fill")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.2)).cornerRadius(20)
            } else {
                Label(compliment.slot.displayName, systemImage: slotIcon)
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.2)).cornerRadius(20)
            }

            if let mood = compliment.mood {
                Text(mood.emoji)
                    .font(.caption)
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(Color.white.opacity(0.15)).cornerRadius(20)
            }

            Spacer()

            Button(action: toggleFavorite) {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .font(.system(size: 15))
                    .foregroundColor(isFav ? Color(hex: "FF6B6B") : .white.opacity(0.7))
                    .scaleEffect(isFav ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3), value: isFav)
            }

            Text(compliment.date, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isNew {
                TypewriterText(
                    fullText: compliment.text,
                    font: compact ? .subheadline : .body,
                    color: .white,
                    lineSpacing: 4
                )
            } else {
                Text(compliment.text)
                    .font(compact ? .subheadline : .body)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }

            if let note = compliment.journalNote, !compact {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "pencil.line")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            actionButton(
                icon: voice.isSpeaking ? "stop.fill" : "speaker.wave.2.fill",
                label: voice.isSpeaking ? "Σταμάτα" : "Άκουσε"
            ) { VoiceService.shared.speak(compliment.text) }

            separator
            actionButton(icon: "square.and.arrow.up", label: "Κοινοποίηση") {
                HapticService.impact(.light); showShare = true
            }
            separator
            actionButton(
                icon: compliment.journalNote != nil ? "pencil.line" : "pencil",
                label: compliment.journalNote != nil ? "Σημείωση ✓" : "Σημείωση"
            ) { HapticService.impact(.light); showJournal = true }
        }
        .padding(.top, 4)
    }

    private var separator: some View {
        Divider().frame(height: 20).background(Color.white.opacity(0.25))
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 14))
                Text(label).font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private func toggleFavorite() {
        profileService.toggleFavorite(id: compliment.id)
        isFav.toggle()
    }

    private var slotIcon: String {
        switch compliment.slot {
        case .morning: return "sunrise.fill"
        case .midMorning: return "sun.max.fill"
        case .afternoon: return "sun.haze.fill"
        case .evening: return "moon.stars.fill"
        }
    }
}

struct LoadingComplimentCard: View {
    let slot: ComplimentSlot
    @State private var pulse = false

    var body: some View {
        ZStack {
            DayMakerGradient(slot: slot)
            VStack(spacing: 14) {
                ProgressView().tint(.white).scaleEffect(1.2)
                Text("Δημιουργώ το μήνυμά σου...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(height: 120)
        .opacity(pulse ? 1 : 0.75)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever()) { pulse = true }
        }
    }
}

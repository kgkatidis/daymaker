// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var profileService: ProfileService
    @StateObject private var streak = StreakService.shared
    @StateObject private var boost = BoostService.shared
    @ObservedObject private var score = ScoreService.shared

    @State private var loadingSlots: Set<ComplimentSlot> = []
    @State private var generatedToday: [ComplimentSlot: Compliment] = [:]
    @State private var newSlots: Set<ComplimentSlot> = []
    @State private var currentHour = Calendar.current.component(.hour, from: Date())

    @State private var showProfile = false
    @State private var showHistory = false
    @State private var showBoost = false
    @State private var showVault = false

    @State private var soulLetter: Compliment? = nil
    @State private var monthlyLetter: Compliment? = nil
    @State private var loadingSpecial: Bool = false
    @State private var showSoulLetter = false
    @State private var showMonthlyLetter = false
    @State private var activeSoulLetter: Compliment? = nil
    @State private var activeMonthlyLetter: Compliment? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                ParticleBackground().ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerSection
                        streakAndScoreSection
                        moodSection
                        specialLetterSection
                        todaySection
                        nextComplimentBanner
                        footerSection
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 100)
                }

                boostFAB
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfile) { ProfileView().environmentObject(profileService) }
            .sheet(isPresented: $showHistory) { ComplimentHistoryView().environmentObject(profileService) }
            .sheet(isPresented: $showBoost) { SurpriseBoostView().environmentObject(profileService) }
            .sheet(isPresented: $showVault) { FavoritesVaultView().environmentObject(profileService) }
            .fullScreenCover(isPresented: $showSoulLetter) {
                if let l = activeSoulLetter { SoulLetterView(compliment: l) }
            }
            .fullScreenCover(isPresented: $showMonthlyLetter) {
                if let l = activeMonthlyLetter { MonthlyLetterView(compliment: l) }
            }
            .onAppear {
                streak.recordToday()
                currentHour = Calendar.current.component(.hour, from: Date())
                syncTodaysCompliments()
                score.recalculate()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("☀️ DayMaker")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()

            Button(action: { HapticService.impact(.light); showVault = true }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "FF6B6B"))
            }
            .padding(.trailing, 4)

            Button(action: { HapticService.impact(.light); showHistory = true }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
            }
            .padding(.trailing, 4)

            Button(action: { HapticService.impact(.light); showProfile = true }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.purple)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var greetingText: String {
        let name = profileService.profile.name.isEmpty ? "" : ", \(profileService.profile.name)"
        switch currentHour {
        case 5..<12: return "Καλημέρα\(name) 🌅"
        case 12..<17: return "Καλό μεσημέρι\(name) ☀️"
        case 17..<21: return "Καλό απόγευμα\(name) 🌤"
        default: return "Καλό βράδυ\(name) 🌙"
        }
    }

    // MARK: - Streak & Score

    private var streakAndScoreSection: some View {
        VStack(spacing: 12) {
            StreakBannerView()
            DayScoreView()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Mood

    @ViewBuilder
    private var moodSection: some View {
        if profileService.todayMood == nil {
            MoodCheckInView { mood in
                autoGenerateAvailable(with: mood)
                score.recalculate()
            }
            .environmentObject(profileService)
            .padding(.horizontal, 20)
        } else {
            HStack(spacing: 10) {
                Text(profileService.todayMood!.emoji).font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Σήμερα: \(profileService.todayMood!.label)")
                        .font(.subheadline.bold())
                    Text("Τα μηνύματά σου είναι προσαρμοσμένα στο mood σου.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemGroupedBackground)))
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Special Letters

    @ViewBuilder
    private var specialLetterSection: some View {
        if profileService.isFirstOfMonth {
            specialCard(
                title: "Μηνιαία Επιστολή 🗓️",
                subtitle: "Η επιστολή ανάπτυξής σου για αυτόν τον μήνα",
                gradient: [Color(hex: "0f0c29"), Color(hex: "302b63")],
                existing: monthlyLetter,
                loading: loadingSpecial,
                onOpen: generateMonthlyLetter,
                onTap: { activeMonthlyLetter = monthlyLetter; showMonthlyLetter = true }
            )
        }
        if profileService.isSunday {
            specialCard(
                title: "Soul Letter ✉️",
                subtitle: "Η εβδομαδιαία επιστολή ψυχής σου",
                gradient: [Color(hex: "1a1a2e"), Color(hex: "0f3460")],
                existing: soulLetter,
                loading: loadingSpecial,
                onOpen: generateSoulLetter,
                onTap: { activeSoulLetter = soulLetter; showSoulLetter = true }
            )
        }
    }

    private func specialCard(title: String, subtitle: String, gradient: [Color],
                             existing: Compliment?, loading: Bool,
                             onOpen: @escaping () -> Void, onTap: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title).font(.headline)
                Spacer()
            }
            .padding(.horizontal, 20)

            if loading && existing == nil {
                ZStack {
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 10) {
                        ProgressView().tint(.white)
                        Text("Ετοιμάζεται...").font(.caption).foregroundColor(.white.opacity(0.8))
                    }.padding(20)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20)).frame(height: 90).padding(.horizontal, 20)
            } else if let letter = existing {
                Button(action: onTap) {
                    ZStack(alignment: .bottomTrailing) {
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(subtitle).font(.caption).foregroundColor(.white.opacity(0.6))
                            Text(letter.text).font(.subheadline).foregroundColor(.white.opacity(0.9))
                                .lineLimit(2).lineSpacing(3)
                        }
                        .padding(18)
                        Text("Άνοιγμα →").font(.caption.bold()).foregroundColor(.white.opacity(0.5)).padding(14)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10, y: 5)
                }
                .padding(.horizontal, 20)
            } else {
                Button(action: onOpen) {
                    HStack {
                        Image(systemName: "envelope.open.fill").foregroundColor(.white)
                        Text("Άνοιξε \(title)").fontWeight(.semibold).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Today

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Σήμερα")
                .font(.headline)
                .padding(.horizontal, 20)

            ForEach(ComplimentSlot.allCases, id: \.rawValue) { slot in
                slotRow(slot)
            }
        }
    }

    @ViewBuilder
    private func slotRow(_ slot: ComplimentSlot) -> some View {
        let isLoading = loadingSlots.contains(slot)
        let generated = generatedToday[slot]
        let isAvailable = currentHour >= slot.hour
        let isNew = newSlots.contains(slot)

        if isLoading {
            LoadingComplimentCard(slot: slot).padding(.horizontal, 20)
        } else if let compliment = generated {
            ComplimentCard(compliment: compliment, compact: false, isNew: isNew)
                .environmentObject(profileService)
                .padding(.horizontal, 20)
                .onTapGesture {
                    profileService.markComplimentRead(id: compliment.id)
                    score.recalculate()
                }
        } else {
            LockedSlotCard(slot: slot, isAvailable: isAvailable) {
                HapticService.impact(.medium)
                generateCompliment(for: slot)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Boost FAB

    private var boostFAB: some View {
        Button(action: {
            HapticService.impact(.heavy)
            showBoost = true
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: boost.canBoost
                                ? [Color(hex: "4776E6"), Color(hex: "8E54E9")]
                                : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    .shadow(color: boost.canBoost ? Color(hex: "8E54E9").opacity(0.5) : .clear,
                            radius: 12, x: 0, y: 6)

                VStack(spacing: 1) {
                    Text("⚡️").font(.system(size: 22))
                    Text(boost.canBoost ? "\(boost.remaining)" : "✓")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .padding(.trailing, 22)
        .padding(.bottom, 36)
        .disabled(!boost.canBoost)
    }

    // MARK: - Next / Footer

    @ViewBuilder
    private var nextComplimentBanner: some View {
        let nextSlot = ComplimentSlot.allCases.first {
            currentHour < $0.hour && generatedToday[$0] == nil
        }
        if let next = nextSlot {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill").foregroundColor(.purple).font(.caption)
                Text("Επόμενο στις \(next.hour):00 \(next.emoji)")
                    .font(.caption).foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
        }
    }

    private var footerSection: some View {
        VStack(spacing: 4) {
            Divider().padding(.horizontal, 20)
            Text("© 2026 Konstantinos Gkatidis · DayMaker")
                .font(.caption2).foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.top, 8)
    }

    // MARK: - Logic

    private func generateCompliment(for slot: ComplimentSlot) {
        loadingSlots.insert(slot)
        let mood = profileService.todayMood
        Task {
            do {
                let text = try await ClaudeService.shared.generateCompliment(
                    profile: profileService.profile, slot: slot, mood: mood)
                let c = Compliment(text: text, slot: slot, mood: mood)
                await MainActor.run {
                    profileService.saveCompliment(c)
                    generatedToday[slot] = c
                    newSlots.insert(slot)
                    loadingSlots.remove(slot)
                    HapticService.success()
                    score.recalculate()
                }
            } catch {
                await MainActor.run {
                    loadingSlots.remove(slot)
                    let text = ClaudeService.shared.generateComplimentOffline(
                        profile: profileService.profile, slot: slot, mood: mood)
                    let c = Compliment(text: text, slot: slot, mood: mood)
                    profileService.saveCompliment(c)
                    generatedToday[slot] = c
                    newSlots.insert(slot)
                    score.recalculate()
                }
            }
        }
    }

    private func generateSoulLetter() {
        guard soulLetter == nil, !loadingSpecial else { return }
        loadingSpecial = true
        Task {
            do {
                let text = try await ClaudeService.shared.generateSoulLetter(profile: profileService.profile)
                let c = Compliment(text: text, slot: .evening, isSoulLetter: true)
                await MainActor.run {
                    soulLetter = c; profileService.saveCompliment(c)
                    loadingSpecial = false
                    activeSoulLetter = c; showSoulLetter = true
                    HapticService.success()
                }
            } catch {
                await MainActor.run { loadingSpecial = false }
            }
        }
    }

    private func generateMonthlyLetter() {
        guard monthlyLetter == nil, !loadingSpecial else { return }
        loadingSpecial = true
        Task {
            do {
                let text = try await ClaudeService.shared.generateMonthlyLetter(profile: profileService.profile)
                let c = Compliment(text: text, slot: .evening, isMonthlyLetter: true)
                await MainActor.run {
                    monthlyLetter = c; profileService.saveCompliment(c)
                    loadingSpecial = false
                    activeMonthlyLetter = c; showMonthlyLetter = true
                    HapticService.success()
                }
            } catch {
                await MainActor.run { loadingSpecial = false }
            }
        }
    }

    private func syncTodaysCompliments() {
        for c in profileService.todaysCompliments {
            if c.isMonthlyLetter { monthlyLetter = c }
            else if c.isSoulLetter { soulLetter = c }
            else { generatedToday[c.slot] = c }
        }
        if let mood = profileService.todayMood {
            autoGenerateAvailable(with: mood)
        }
    }

    private func autoGenerateAvailable(with mood: MoodState) {
        for slot in ComplimentSlot.allCases {
            if currentHour >= slot.hour && generatedToday[slot] == nil {
                generateCompliment(for: slot)
            }
        }
    }
}

struct LockedSlotCard: View {
    let slot: ComplimentSlot
    let isAvailable: Bool
    let onGenerate: () -> Void

    var body: some View {
        Button(action: { if isAvailable { onGenerate() } }) {
            HStack(spacing: 14) {
                Text(slot.emoji).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(isAvailable ? .primary : .secondary)
                    Text(isAvailable ? "Πάτα για το μήνυμά σου" : "Διαθέσιμο στις \(slot.hour):00")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isAvailable ? "sparkles" : "lock.fill")
                    .foregroundColor(isAvailable ? .purple : Color(UIColor.tertiaryLabel))
                    .font(.system(size: 18))
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemGroupedBackground)))
        }
        .disabled(!isAvailable)
    }
}

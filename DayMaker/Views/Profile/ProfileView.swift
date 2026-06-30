// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileService: ProfileService
    @Environment(\.dismiss) var dismiss
    @State private var profile: UserProfile = UserProfile()
    @State private var apiKey: String = ""
    @State private var showResetAlert = false
    @State private var showReOnboarding = false
    @State private var isSaved = false
    @State private var showNotifAlert = false
    @State private var notifStatus: String = ""

    var body: some View {
        NavigationStack {
            Form {
                personalSection
                apiKeySection
                notificationSection
                statsSection
                dangerZone
                copyrightSection
            }
            .navigationTitle("Προφίλ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Κλείσιμο") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Αποθήκευση") { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(isSaved ? .green : .purple)
                }
            }
            .onAppear {
                profile = profileService.profile
                apiKey = UserDefaults.standard.string(forKey: "daymaker_api_key") ?? ""
            }
            .alert("Επαναφορά εφαρμογής", isPresented: $showResetAlert) {
                Button("Ακύρωση", role: .cancel) {}
                Button("Επαναφορά", role: .destructive) { resetAll() }
            } message: {
                Text("Αυτό θα διαγράψει το προφίλ σου και όλα τα μηνύματα. Είσαι σίγουρος/η;")
            }
            .alert(notifStatus, isPresented: $showNotifAlert) {
                Button("OK") {}
            }
            .fullScreenCover(isPresented: $showReOnboarding) {
                OnboardingView()
                    .environmentObject(profileService)
            }
        }
    }

    private var personalSection: some View {
        Section("Προσωπικά στοιχεία") {
            profileField(label: "Όνομα", value: $profile.name)
            profileField(label: "Ηλικία", value: $profile.age)
            profileField(label: "Επάγγελμα", value: $profile.profession)
            profileField(label: "Πάθη / Χόμπι", value: $profile.passionsAndHobbies)
            profileField(label: "Στόχοι", value: $profile.goalsNextYear)
            profileField(label: "Φιλοσοφία ζωής", value: $profile.lifePhilosophy)
        }
    }

    private var apiKeySection: some View {
        Section {
            SecureField("sk-ant-...", text: $apiKey)
                .font(.system(.body, design: .monospaced))
            Text("Χρειάζεται Claude API key από το console.anthropic.com για τη δημιουργία εξατομικευμένων μηνυμάτων.")
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Claude API Key")
        }
    }

    private var notificationSection: some View {
        Section("Ειδοποιήσεις") {
            ForEach(ComplimentSlot.allCases, id: \.rawValue) { slot in
                HStack {
                    Text(slot.emoji)
                    Text(slot.displayName)
                    Spacer()
                    Text("\(slot.hour):00")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: recheckNotifications) {
                Label("Επαναπρογραμματισμός ειδοποιήσεων", systemImage: "bell.badge.fill")
                    .foregroundColor(.purple)
            }
        }
    }

    private var statsSection: some View {
        Section("Στατιστικά") {
            HStack {
                Label("Συνολικά μηνύματα", systemImage: "sparkles")
                Spacer()
                Text("\(profileService.compliments.count)")
                    .foregroundColor(.secondary)
            }
            HStack {
                Label("Μέλος από", systemImage: "calendar")
                Spacer()
                Text(profileService.profile.createdAt, format: .dateTime.day().month().year())
                    .foregroundColor(.secondary)
            }
        }
    }

    private var dangerZone: some View {
        Section("Διαχείριση") {
            Button(action: { showReOnboarding = true }) {
                Label("Ξαναδώσε τη συνέντευξη", systemImage: "arrow.counterclockwise")
                    .foregroundColor(.orange)
            }
            Button(action: { showResetAlert = true }) {
                Label("Επαναφορά εφαρμογής", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
    }

    private var copyrightSection: some View {
        Section {
            VStack(spacing: 4) {
                Text("DayMaker")
                    .font(.headline)
                Text("© 2026 Konstantinos Gkatidis")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Powered by Claude AI")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private func profileField(label: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField(label, text: value, axis: .vertical)
                .lineLimit(1...4)
        }
    }

    private func save() {
        UserDefaults.standard.set(apiKey, forKey: "daymaker_api_key")
        profileService.saveProfile(profile)
        NotificationService.shared.scheduleDaily(for: profile)
        withAnimation {
            isSaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { isSaved = false }
        }
    }

    private func recheckNotifications() {
        Task {
            let status = await NotificationService.shared.checkPermission()
            await MainActor.run {
                switch status {
                case .authorized:
                    NotificationService.shared.scheduleDaily(for: profileService.profile)
                    notifStatus = "Οι ειδοποιήσεις επαναπρογραμματίστηκαν επιτυχώς!"
                case .denied:
                    notifStatus = "Οι ειδοποιήσεις είναι απενεργοποιημένες. Άνοιξε τις Ρυθμίσεις iOS για να τις ενεργοποιήσεις."
                default:
                    notifStatus = "Παρακαλώ δώσε άδεια για ειδοποιήσεις από τις Ρυθμίσεις."
                }
                showNotifAlert = true
            }
        }
    }

    private func resetAll() {
        profileService.resetAll()
        NotificationService.shared.cancelAll()
        dismiss()
    }
}

struct APIKeySetupView: View {
    @Binding var apiKey: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)

                    Text("Ένα τελευταίο βήμα")
                        .font(.title2.bold())

                    Text("Για να δημιουργώ εξατομικευμένα μηνύματα μόνο για σένα, χρειάζομαι ένα Claude API Key από την Anthropic. Είναι δωρεάν να ξεκινήσεις.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 12) {
                    SecureField("Επικόλλησε το API key εδώ...", text: $apiKey)
                        .padding(14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .font(.system(.body, design: .monospaced))

                    Text("console.anthropic.com → API Keys")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onSave) {
                        Text("Έτοιμο! Ξεκινάμε 🚀")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .disabled(apiKey.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(apiKey.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)

                    Button("Παράλειψη προς το παρόν") {
                        onSave()
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}

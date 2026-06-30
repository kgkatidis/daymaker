// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct OnboardingQuestion {
    let id: Int
    let question: String
    let placeholder: String
    let emoji: String
    let hint: String
    let keyPath: WritableKeyPath<UserProfile, String>
}

let onboardingQuestions: [OnboardingQuestion] = [
    OnboardingQuestion(id: 0, question: "Πώς σε λένε;", placeholder: "Το όνομά σου...", emoji: "👋", hint: "Αυτό είναι η αρχή μιας πολύ ξεχωριστής γνωριμίας.", keyPath: \.name),
    OnboardingQuestion(id: 1, question: "Πόσο χρονών είσαι;", placeholder: "Η ηλικία σου...", emoji: "🎂", hint: "Κάθε χρόνος που πέρασες σε έκανε πιο σοφό/ή.", keyPath: \.age),
    OnboardingQuestion(id: 2, question: "Τι κάνεις για δουλειά ή σπουδές;", placeholder: "Επάγγελμα ή σπουδές...", emoji: "💼", hint: "Η δουλειά σου δεν σε ορίζει, αλλά μαρτυράει πολλά για σένα.", keyPath: \.profession),
    OnboardingQuestion(id: 3, question: "Ποιο είναι το πράγμα που έχεις καταφέρει και σε κάνει πιο περήφανο/η;", placeholder: "Μίλα μου για αυτό...", emoji: "🏆", hint: "Δεν χρειάζεται να είναι μεγάλο. Αυτό που νιώθεις εσύ σημαντικό, είναι.", keyPath: \.proudestAchievement),
    OnboardingQuestion(id: 4, question: "Ποια είναι τα πάθη ή οι ενασχολήσεις σου;", placeholder: "Τι σε ζωντανεύει...", emoji: "❤️‍🔥", hint: "Αυτά είναι τα χρώματα της ψυχής σου.", keyPath: \.passionsAndHobbies),
    OnboardingQuestion(id: 5, question: "Ποιο χαρακτηριστικό της προσωπικότητάς σου αγαπάς περισσότερο;", placeholder: "Κάτι που σε κάνει εσένα...", emoji: "✨", hint: "Αυτό το ξέρεις καλύτερα από τον καθένα.", keyPath: \.personalityTrait),
    OnboardingQuestion(id: 6, question: "Ποιο είναι το μεγαλύτερο σου όνειρο ή στόχος για το επόμενο χρόνο;", placeholder: "Το όνειρό σου...", emoji: "🚀", hint: "Ακόμα κι αν φαίνεται τολμηρό — ειδικά αν φαίνεται τολμηρό.", keyPath: \.goalsNextYear),
    OnboardingQuestion(id: 7, question: "Τι σου λένε συχνά οι άνθρωποι γύρω σου ότι κάνεις καλά;", placeholder: "Τα κομπλιμέντα που παίρνεις...", emoji: "🗣️", hint: "Οι άλλοι βλέπουν πράγματα σε μας που εμείς δεν βλέπουμε.", keyPath: \.frequentCompliments),
    OnboardingQuestion(id: 8, question: "Μοιράσου μαζί μου μια δυσκολία που έχεις ξεπεράσει πρόσφατα.", placeholder: "Αυτό που ξεπέρασες...", emoji: "💪", hint: "Κάθε εμπόδιο που ξεπέρασες σε έκανε αυτό που είσαι σήμερα.", keyPath: \.recentChallenge),
    OnboardingQuestion(id: 9, question: "Τι σε κάνει μοναδικό/ή; Τι έχεις εσύ που δεν το έχουν όλοι;", placeholder: "Η μοναδικότητά σου...", emoji: "🦋", hint: "Υπάρχει κάτι — ακόμα κι αν δυσκολεύεσαι να το πεις.", keyPath: \.whatMakesUnique),
    OnboardingQuestion(id: 10, question: "Ποιο φυσικό χαρακτηριστικό σου αγαπάς;", placeholder: "Κάτι που σου αρέσει σε σένα...", emoji: "🪞", hint: "Κοίταξε σωστά. Υπάρχει.", keyPath: \.physicalFeatureLove),
    OnboardingQuestion(id: 11, question: "Πώς ξεκινάς συνήθως την ημέρα σου;", placeholder: "Η πρωινή ρουτίνα σου...", emoji: "🌅", hint: "Ο τρόπος που ξεκινάς τη μέρα μαρτυράει τον τρόπο που ζεις.", keyPath: \.morningRoutine),
    OnboardingQuestion(id: 12, question: "Ποια είναι η κατάσταση των σχέσεών σου; (οικογένεια, φίλοι, σύντροφος)", placeholder: "Λίγα λόγια για τις σχέσεις σου...", emoji: "🤝", hint: "Οι άνθρωποι γύρω μας μας ορίζουν — με τον καλό τρόπο.", keyPath: \.relationshipStatus),
    OnboardingQuestion(id: 13, question: "Αν έπρεπε να συνοψίσεις τη φιλοσοφία ζωής σου σε μια πρόταση, τι θα έλεγες;", placeholder: "Η φιλοσοφία σου...", emoji: "🧠", hint: "Αυτή είναι η ουσία σου.", keyPath: \.lifePhilosophy),
]

struct OnboardingView: View {
    @EnvironmentObject var profileService: ProfileService
    @State private var profile = UserProfile()
    @State private var currentIndex = 0
    @State private var answer = ""
    @State private var isAnimating = false
    @State private var showIntro = true
    @State private var apiKey = ""
    @State private var showAPIKeySheet = false

    private var current: OnboardingQuestion { onboardingQuestions[currentIndex] }
    private var isLast: Bool { currentIndex == onboardingQuestions.count - 1 }
    private var progress: Double { Double(currentIndex) / Double(onboardingQuestions.count) }

    var body: some View {
        ZStack {
            DayMakerGradient(slot: nil)
                .ignoresSafeArea()

            if showIntro {
                IntroView(onStart: {
                    withAnimation(.easeInOut(duration: 0.5)) { showIntro = false }
                })
                .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    progressBar
                    questionContent
                    Spacer()
                    nextButton
                        .padding(.bottom, 40)
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showAPIKeySheet) {
            APIKeySetupView(apiKey: $apiKey, onSave: {
                UserDefaults.standard.set(apiKey, forKey: "daymaker_api_key")
                finishOnboarding()
            })
        }
    }

    private var progressBar: some View {
        VStack(spacing: 4) {
            HStack {
                Text("\(currentIndex + 1) / \(onboardingQuestions.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var questionContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(current.emoji)
                .font(.system(size: 56))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)

            VStack(alignment: .leading, spacing: 8) {
                Text(current.question)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 15)

                Text(current.hint)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 10)
            }

            TextEditor(text: $answer)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .font(.body)
                .overlay(
                    Group {
                        if answer.isEmpty {
                            Text(current.placeholder)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 16)
                                .padding(.top, 18)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .allowsHitTesting(false)
                        }
                    }
                )
                .opacity(isAnimating ? 1 : 0)
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .onAppear { animateIn() }
    }

    private var nextButton: some View {
        Button(action: advance) {
            HStack {
                Text(isLast ? "Ολοκλήρωση" : "Επόμενο")
                    .fontWeight(.semibold)
                Image(systemName: isLast ? "checkmark" : "arrow.right")
            }
            .foregroundColor(Color("AccentPurple"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.white)
            .cornerRadius(16)
        }
        .padding(.horizontal, 28)
        .disabled(answer.trimmingCharacters(in: .whitespaces).isEmpty)
        .opacity(answer.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
    }

    private func advance() {
        let trimmed = answer.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        profile[keyPath: current.keyPath] = trimmed

        if isLast {
            showAPIKeySheet = true
        } else {
            withAnimation(.easeOut(duration: 0.2)) { isAnimating = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentIndex += 1
                answer = ""
                animateIn()
            }
        }
    }

    private func animateIn() {
        isAnimating = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
            isAnimating = true
        }
    }

    private func finishOnboarding() {
        var completed = profile
        completed.isOnboardingComplete = true
        profileService.saveProfile(completed)
        Task {
            _ = await NotificationService.shared.requestPermission()
            NotificationService.shared.scheduleDaily(for: completed)
        }
    }
}

struct IntroView: View {
    let onStart: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("☀️")
                    .font(.system(size: 80))
                    .scaleEffect(appeared ? 1 : 0.5)

                Text("DayMaker")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Η εφαρμογή που φτιάχνει\nτη μέρα σου")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)

            Spacer()

            VStack(spacing: 16) {
                Text("Πριν ξεκινήσουμε, θέλω να σε γνωρίσω καλά. Θα σου κάνω μερικές ερωτήσεις — απάντα ειλικρινά. Όσο περισσότερα μου πεις, τόσο πιο ξεχωριστά θα είναι τα μηνύματά σου.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: onStart) {
                    Text("Ας ξεκινήσουμε →")
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentPurple"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 28)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3)) {
                appeared = true
            }
        }
    }
}

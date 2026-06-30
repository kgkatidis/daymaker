// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.models

import java.util.UUID

data class UserProfile(
    val name: String = "",
    val age: String = "",
    val profession: String = "",
    val proudestAchievement: String = "",
    val passionsAndHobbies: String = "",
    val personalityTrait: String = "",
    val goalsNextYear: String = "",
    val frequentCompliments: String = "",
    val recentChallenge: String = "",
    val whatMakesUnique: String = "",
    val physicalFeatureLove: String = "",
    val morningRoutine: String = "",
    val relationshipStatus: String = "",
    val lifePhilosophy: String = "",
    val createdAt: Long = System.currentTimeMillis(),
    val isOnboardingComplete: Boolean = false
) {
    val summaryForAI: String get() = """
        Name: $name
        Age: $age
        Profession: $profession
        Proudest achievement: $proudestAchievement
        Passions & hobbies: $passionsAndHobbies
        Personality trait they love: $personalityTrait
        Goals for next year: $goalsNextYear
        What people often compliment them on: $frequentCompliments
        Recent challenge overcome: $recentChallenge
        What makes them unique: $whatMakesUnique
        Physical feature they love: $physicalFeatureLove
        Morning routine: $morningRoutine
        Relationship status: $relationshipStatus
        Life philosophy: $lifePhilosophy
    """.trimIndent()
}

enum class ComplimentSlot(val displayName: String, val hour: Int, val emoji: String) {
    MORNING("Πρωινό", 8, "🌅"),
    MID_MORNING("Μεσημέρι", 11, "☀️"),
    AFTERNOON("Απόγευμα", 15, "🌤"),
    EVENING("Βράδυ", 20, "🌙");

    val systemPromptContext: String get() = when (this) {
        MORNING -> "It's early morning. Give them an energizing, warm compliment that sets a positive tone."
        MID_MORNING -> "It's mid-morning. Give them a genuine, motivating compliment to keep their energy up."
        AFTERNOON -> "It's afternoon. Give them a heartfelt compliment that reminds them of their inner strength."
        EVENING -> "It's evening. Give them a warm, reflective compliment celebrating who they are."
    }
}

enum class MoodState(val emoji: String, val label: String, val promptContext: String) {
    ROUGH("😔", "Δύσκολα", "This person is having a rough day. Give them extra warmth and validation."),
    MEH("😐", "Έτσι κι έτσι", "This person is feeling neutral. Lift their spirits with quiet strength."),
    OKAY("🙂", "Καλά", "This person is doing okay. Add a spark of joy to their decent day."),
    GOOD("😊", "Πολύ καλά", "This person is in a good mood. Be celebratory and affirming."),
    AMAZING("🤩", "Τέλεια!", "This person is feeling amazing! Match their energy with enthusiastic joy.")
}

data class Compliment(
    val id: String = UUID.randomUUID().toString(),
    val text: String,
    val slot: ComplimentSlot,
    val date: Long = System.currentTimeMillis(),
    var isRead: Boolean = false,
    val mood: MoodState? = null,
    var journalNote: String? = null,
    val isSoulLetter: Boolean = false,
    val isMonthlyLetter: Boolean = false,
    var isFavorite: Boolean = false
)

data class OnboardingQuestion(
    val id: Int,
    val question: String,
    val placeholder: String,
    val emoji: String,
    val hint: String,
    val field: String
)

val ONBOARDING_QUESTIONS = listOf(
    OnboardingQuestion(0, "Πώς σε λένε;", "Το όνομά σου...", "👋", "Αυτό είναι η αρχή μιας πολύ ξεχωριστής γνωριμίας.", "name"),
    OnboardingQuestion(1, "Πόσο χρονών είσαι;", "Η ηλικία σου...", "🎂", "Κάθε χρόνος σε έκανε πιο σοφό/ή.", "age"),
    OnboardingQuestion(2, "Τι κάνεις για δουλειά ή σπουδές;", "Επάγγελμα ή σπουδές...", "💼", "Η δουλειά σου μαρτυράει πολλά για σένα.", "profession"),
    OnboardingQuestion(3, "Ποιο είναι το πράγμα που σε κάνει πιο περήφανο/η;", "Μίλα μου για αυτό...", "🏆", "Δεν χρειάζεται να είναι μεγάλο.", "proudestAchievement"),
    OnboardingQuestion(4, "Ποια είναι τα πάθη ή οι ενασχολήσεις σου;", "Τι σε ζωντανεύει...", "❤️‍🔥", "Αυτά είναι τα χρώματα της ψυχής σου.", "passionsAndHobbies"),
    OnboardingQuestion(5, "Ποιο χαρακτηριστικό της προσωπικότητάς σου αγαπάς;", "Κάτι που σε κάνει εσένα...", "✨", "Αυτό το ξέρεις καλύτερα από τον καθένα.", "personalityTrait"),
    OnboardingQuestion(6, "Ποιος είναι ο μεγαλύτερος στόχος σου για το επόμενο χρόνο;", "Το όνειρό σου...", "🚀", "Ακόμα κι αν φαίνεται τολμηρό.", "goalsNextYear"),
    OnboardingQuestion(7, "Τι σου λένε συχνά ότι κάνεις καλά;", "Τα κομπλιμέντα που παίρνεις...", "🗣️", "Οι άλλοι βλέπουν πράγματα που εμείς δεν βλέπουμε.", "frequentCompliments"),
    OnboardingQuestion(8, "Μια δυσκολία που έχεις ξεπεράσει πρόσφατα;", "Αυτό που ξεπέρασες...", "💪", "Κάθε εμπόδιο σε έκανε αυτό που είσαι.", "recentChallenge"),
    OnboardingQuestion(9, "Τι σε κάνει μοναδικό/ή;", "Η μοναδικότητά σου...", "🦋", "Υπάρχει κάτι — ακόμα κι αν δυσκολεύεσαι να το πεις.", "whatMakesUnique"),
    OnboardingQuestion(10, "Ποιο φυσικό χαρακτηριστικό σου αγαπάς;", "Κάτι που σου αρέσει...", "🪞", "Κοίταξε σωστά. Υπάρχει.", "physicalFeatureLove"),
    OnboardingQuestion(11, "Πώς ξεκινάς συνήθως την ημέρα σου;", "Η πρωινή ρουτίνα σου...", "🌅", "Ο τρόπος που ξεκινάς μαρτυράει τον τρόπο που ζεις.", "morningRoutine"),
    OnboardingQuestion(12, "Λίγα λόγια για τις σχέσεις σου;", "Οικογένεια, φίλοι, σύντροφος...", "🤝", "Οι άνθρωποι γύρω μας μας ορίζουν.", "relationshipStatus"),
    OnboardingQuestion(13, "Η φιλοσοφία ζωής σου σε μια πρόταση;", "Η φιλοσοφία σου...", "🧠", "Αυτή είναι η ουσία σου.", "lifePhilosophy")
)

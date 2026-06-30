// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import Foundation

final class ClaudeService {
    static let shared = ClaudeService()

    private let apiURL = "https://api.anthropic.com/v1/messages"
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "daymaker_api_key") ?? ""
    }

    private init() {}

    func generateCompliment(profile: UserProfile, slot: ComplimentSlot, mood: MoodState? = nil) async throws -> String {
        guard !apiKey.isEmpty else { throw ClaudeError.missingAPIKey }

        let moodContext = mood.map { "\n\nMood context: \($0.promptContext)" } ?? ""

        let systemPrompt = """
        You are a deeply thoughtful personal companion who knows someone intimately and genuinely admires them. \
        Your job is to give them one beautiful, personalized compliment that feels like it came from a dear friend who truly sees them.
        \(slot.systemPromptContext)\(moodContext)

        Rules:
        - Write ONLY the compliment text — no labels, no intro, no quotes, no signature
        - Make it feel deeply personal, referencing specific real details about who they are
        - 2–4 sentences. Never generic. Never hollow.
        - Sound like a wise, warm human who loves them — not a chatbot
        - Use their name naturally once within the text
        - Vary the style: sometimes poetic, sometimes grounded, sometimes playful — always heartfelt
        - Language: match the language of the profile (Greek or English)
        """

        let userMessage = """
        Everything you know about this person:

        \(profile.summaryForAI)

        Write them a compliment for this exact moment.
        """

        return try await callAPI(system: systemPrompt, user: userMessage, maxTokens: 300)
    }

    func generateSoulLetter(profile: UserProfile) async throws -> String {
        guard !apiKey.isEmpty else { throw ClaudeError.missingAPIKey }

        let systemPrompt = """
        You are a wise, warm mentor who has watched someone live their life and has profound admiration for who they are. \
        Once a week, on Sunday evening, you write them a "Soul Letter" — a deeper, more philosophical reflection on their worth and journey. \
        This is not a compliment. It's a letter. A moment of true seeing.

        Rules:
        - Write 4–6 sentences of genuine depth
        - Reference specific things about them — their profession, passions, philosophy, challenges overcome
        - Be poetic but grounded. Spiritual but real.
        - Make them feel deeply, profoundly seen
        - Sign it: "— DayMaker"
        - Language: match the profile language (Greek or English)
        """

        let userMessage = """
        The person you know deeply:

        \(profile.summaryForAI)

        Write their Sunday Soul Letter.
        """

        return try await callAPI(system: systemPrompt, user: userMessage, maxTokens: 500)
    }

    func callBoost(system: String, user: String) async throws -> String {
        guard !apiKey.isEmpty else { throw ClaudeError.missingAPIKey }
        return try await callAPI(system: system, user: user, maxTokens: 200)
    }

    func generateMonthlyLetter(profile: UserProfile) async throws -> String {
        guard !apiKey.isEmpty else { throw ClaudeError.missingAPIKey }

        let monthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
        let system = """
        You are a wise, caring mentor who has known this person for a full month and has watched them navigate their life. \
        Write them a "Monthly Growth Letter" — a heartfelt, philosophical reflection on who they are, how they've been showing up, \
        and what you imagine they've grown into this past month. This is not a compliment — it's a letter of deep recognition. \
        5-7 sentences. Poetic but grounded. Reference specific things about them. Sign it: "— DayMaker, \(monthName)". \
        Language: match the profile language (Greek or English).
        """
        let user = "The person you've known this month:\n\n\(profile.summaryForAI)"
        return try await callAPI(system: system, user: user, maxTokens: 600)
    }

    private func callAPI(system: String, user: String, maxTokens: Int) async throws -> String {
        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": maxTokens,
            "system": system,
            "messages": [["role": "user", "content": user]]
        ]

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw ClaudeError.invalidResponse }
        guard http.statusCode == 200 else { throw ClaudeError.apiError(http.statusCode) }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String else {
            throw ClaudeError.parseError
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateComplimentOffline(profile: UserProfile, slot: ComplimentSlot, mood: MoodState? = nil) -> String {
        let name = profile.name.isEmpty ? "φίλε" : profile.name
        let moodPrefix: String = {
            guard let m = mood else { return "" }
            switch m {
            case .rough: return "\(name), ακόμα και στις πιο δύσκολες μέρες — ειδικά σε αυτές — δείχνεις πόσο δυνατός/ή είσαι. "
            case .amazing: return "Ναι! Αυτή η ενέργεια που νιώθεις σήμερα; Είναι ακριβώς αυτό που σε κάνει εσένα. "
            default: return ""
            }
        }()

        let fallbacks = [
            "\(moodPrefix)\(name), η αφοσίωσή σου σε αυτά που αγαπάς είναι κάτι που λίγοι άνθρωποι έχουν. Αυτό σε κάνει ξεχωριστό/ή.",
            "\(moodPrefix)Ξέρεις \(name), το γεγονός ότι τα καταφέρνεις κάθε μέρα — ακόμα και στις δύσκολες — δείχνει πόσο δυνατός/ή χαρακτήρας είσαι.",
            "\(moodPrefix)\(name), η μοναδικότητά σου δεν είναι τυχαία. Είναι αποτέλεσμα ετών σκέψης, εμπειριών και ανάπτυξης.",
            "\(moodPrefix)Κοιτάζοντάς σε \(name), βλέπω κάποιον/α που αξίζει κάθε καλό πράγμα που έρχεται. Και έρχονται.",
        ]
        return fallbacks[slot.rawValue % fallbacks.count]
    }
}

enum ClaudeError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(Int)
    case parseError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Λείπει το API key. Πήγαινε στις Ρυθμίσεις."
        case .invalidResponse: return "Άκυρη απάντηση από τον server."
        case .apiError(let code): return "Σφάλμα API: \(code)"
        case .parseError: return "Σφάλμα επεξεργασίας απάντησης."
        }
    }
}

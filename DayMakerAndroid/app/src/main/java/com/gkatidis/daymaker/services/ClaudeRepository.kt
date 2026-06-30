// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.services

import com.gkatidis.daymaker.models.ComplimentSlot
import com.gkatidis.daymaker.models.MoodState
import com.gkatidis.daymaker.models.UserProfile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

class ClaudeRepository {

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
        .readTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
        .build()

    private val apiUrl = "https://api.anthropic.com/v1/messages"

    suspend fun generateCompliment(
        profile: UserProfile,
        slot: ComplimentSlot,
        mood: MoodState?,
        apiKey: String
    ): String = withContext(Dispatchers.IO) {
        val moodCtx = mood?.let { "\n\nMood context: ${it.promptContext}" } ?: ""
        val system = """
            You are a deeply thoughtful personal companion who knows someone intimately and genuinely admires them.
            ${slot.systemPromptContext}$moodCtx
            Rules:
            - Write ONLY the compliment text — no labels, no intro, no quotes
            - Make it deeply personal, referencing specific details about who they are
            - 2–4 sentences. Never generic. Never hollow.
            - Sound like a wise warm human who loves them — not a bot
            - Use their name naturally once
            - Language: match the profile (Greek or English)
        """.trimIndent()
        val user = "Everything you know about this person:\n\n${profile.summaryForAI}\n\nWrite them a compliment for this moment."
        call(system, user, 300, apiKey)
    }

    suspend fun generateSoulLetter(profile: UserProfile, apiKey: String): String = withContext(Dispatchers.IO) {
        val system = """
            You are a wise mentor who watches this person live their life and has deep admiration for who they are.
            Write them a Sunday "Soul Letter" — a deep, philosophical reflection on their worth and journey.
            4–6 sentences. Poetic but grounded. Reference specific things. Sign it: "— DayMaker".
            Language: match the profile (Greek or English).
        """.trimIndent()
        val user = "The person you know deeply:\n\n${profile.summaryForAI}\n\nWrite their Sunday Soul Letter."
        call(system, user, 500, apiKey)
    }

    suspend fun generateMonthlyLetter(profile: UserProfile, apiKey: String): String = withContext(Dispatchers.IO) {
        val months = listOf("Ιανουαρίου","Φεβρουαρίου","Μαρτίου","Απριλίου","Μαΐου","Ιουνίου",
                            "Ιουλίου","Αυγούστου","Σεπτεμβρίου","Οκτωβρίου","Νοεμβρίου","Δεκεμβρίου")
        val month = months[Calendar.getInstance().get(Calendar.MONTH)]
        val system = """
            You are a caring mentor writing a Monthly Growth Letter for someone you've known for a full month.
            5–7 sentences of depth. Poetic but real. Reference specific things about them.
            Sign it: "— DayMaker, $month". Language: match the profile (Greek or English).
        """.trimIndent()
        val user = "The person you've known this month:\n\n${profile.summaryForAI}\n\nWrite their Monthly Letter."
        call(system, user, 600, apiKey)
    }

    suspend fun generateBoost(profile: UserProfile, apiKey: String): String = withContext(Dispatchers.IO) {
        val system = """
            This person needs an instant emotional boost RIGHT NOW.
            Give them one powerful, immediate, deeply personal compliment that cuts to their worth.
            Urgent, real, loving — like a best friend who truly sees them. 2–3 sentences max.
            Use their name. Language: match the profile (Greek or English).
        """.trimIndent()
        val user = "The person who needs a boost:\n\n${profile.summaryForAI}"
        call(system, user, 200, apiKey)
    }

    private fun call(system: String, user: String, maxTokens: Int, apiKey: String): String {
        val body = JSONObject().apply {
            put("model", "claude-sonnet-4-6")
            put("max_tokens", maxTokens)
            put("system", system)
            put("messages", JSONArray().put(JSONObject().apply {
                put("role", "user")
                put("content", user)
            }))
        }

        val request = Request.Builder()
            .url(apiUrl)
            .post(body.toString().toRequestBody("application/json".toMediaType()))
            .addHeader("x-api-key", apiKey)
            .addHeader("anthropic-version", "2023-06-01")
            .addHeader("Content-Type", "application/json")
            .build()

        val response = client.newCall(request).execute()
        val json = JSONObject(response.body!!.string())
        return json.getJSONArray("content").getJSONObject(0).getString("text").trim()
    }

    fun fallbackCompliment(profile: UserProfile, slot: ComplimentSlot, mood: MoodState?): String {
        val name = profile.name.ifEmpty { "φίλε" }
        val prefix = if (mood == MoodState.ROUGH) "$name, ακόμα και στις πιο δύσκολες μέρες δείχνεις πόσο δυνατός/ή είσαι. " else ""
        val options = listOf(
            "${prefix}$name, η αφοσίωσή σου σε αυτά που αγαπάς είναι κάτι που λίγοι άνθρωποι έχουν.",
            "${prefix}Ξέρεις $name, το γεγονός ότι τα καταφέρνεις κάθε μέρα δείχνει πόσο δυνατός/ή χαρακτήρας είσαι.",
            "${prefix}$name, η μοναδικότητά σου δεν είναι τυχαία. Είναι αποτέλεσμα ετών σκέψης και ανάπτυξης.",
            "${prefix}Κοιτάζοντάς σε $name, βλέπω κάποιον/α που αξίζει κάθε καλό πράγμα. Και έρχονται."
        )
        return options[slot.ordinal % options.size]
    }
}

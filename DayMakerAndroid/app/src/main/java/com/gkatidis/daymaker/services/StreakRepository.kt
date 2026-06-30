// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.services

import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.util.*

private val Context.streakStore by preferencesDataStore(name = "daymaker_streak")

class StreakRepository(private val context: Context) {

    private object Keys {
        val CURRENT  = intPreferencesKey("current")
        val LONGEST  = intPreferencesKey("longest")
        val TOTAL    = intPreferencesKey("total")
        val LAST_DAY = longPreferencesKey("last_day")
    }

    data class StreakData(val current: Int, val longest: Int, val total: Int)

    val streakFlow: Flow<StreakData> = context.streakStore.data.map { prefs ->
        StreakData(
            current = prefs[Keys.CURRENT] ?: 0,
            longest = prefs[Keys.LONGEST] ?: 0,
            total   = prefs[Keys.TOTAL] ?: 0
        )
    }

    suspend fun recordToday() {
        val today = startOfToday()
        context.streakStore.edit { prefs ->
            val lastDay = prefs[Keys.LAST_DAY] ?: 0L
            val lastStart = startOfDay(lastDay)
            if (lastStart == today) return@edit

            val current = prefs[Keys.CURRENT] ?: 0
            val daysDiff = ((today - lastStart) / (1000 * 60 * 60 * 24)).toInt()
            val newCurrent = if (daysDiff == 1) current + 1 else 1
            val longest = maxOf(prefs[Keys.LONGEST] ?: 0, newCurrent)

            prefs[Keys.CURRENT]  = newCurrent
            prefs[Keys.LONGEST]  = longest
            prefs[Keys.TOTAL]    = (prefs[Keys.TOTAL] ?: 0) + 1
            prefs[Keys.LAST_DAY] = System.currentTimeMillis()
        }
    }

    suspend fun reset() {
        context.streakStore.edit { it.clear() }
    }

    private fun startOfToday() = startOfDay(System.currentTimeMillis())
    private fun startOfDay(time: Long): Long = Calendar.getInstance().apply {
        timeInMillis = time
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    fun streakEmoji(current: Int) = when (current) {
        0 -> "✨"; in 1..3 -> "🔥"; in 4..7 -> "🔥🔥"; in 8..14 -> "⚡️🔥"; else -> "🏆🔥"
    }

    fun streakMessage(current: Int) = when (current) {
        0 -> "Ξεκίνα σήμερα!"; 1 -> "Ξεκίνησες!"
        in 2..4 -> "$current μέρες στη σειρά"; in 5..9 -> "$current μέρες — συνέχισε!"
        in 10..29 -> "$current μέρες — απίστευτο!"; else -> "$current μέρες — θρυλικός!"
    }
}

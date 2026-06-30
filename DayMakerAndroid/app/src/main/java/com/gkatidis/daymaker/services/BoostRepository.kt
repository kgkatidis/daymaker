// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.services

import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.util.Calendar

private val Context.boostStore by preferencesDataStore(name = "daymaker_boost")

class BoostRepository(private val context: Context) {

    private object Keys {
        val COUNT = intPreferencesKey("count")
        val DATE  = longPreferencesKey("date")
    }

    val MAX_PER_DAY = 3

    val remainingFlow: Flow<Int> = context.boostStore.data.map { prefs ->
        val date = prefs[Keys.DATE] ?: 0L
        val used = if (isToday(date)) prefs[Keys.COUNT] ?: 0 else 0
        MAX_PER_DAY - used
    }

    suspend fun canBoost(): Boolean = remainingFlow.first() > 0

    suspend fun useBoost() {
        context.boostStore.edit { prefs ->
            val date = prefs[Keys.DATE] ?: 0L
            val used = if (isToday(date)) prefs[Keys.COUNT] ?: 0 else 0
            prefs[Keys.COUNT] = used + 1
            prefs[Keys.DATE]  = System.currentTimeMillis()
        }
    }

    suspend fun reset() { context.boostStore.edit { it.clear() } }

    private fun isToday(time: Long): Boolean {
        val cal = Calendar.getInstance()
        val today = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        return time >= today
    }
}

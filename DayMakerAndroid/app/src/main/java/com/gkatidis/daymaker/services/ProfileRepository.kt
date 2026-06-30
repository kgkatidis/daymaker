// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.services

import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.gkatidis.daymaker.models.Compliment
import com.gkatidis.daymaker.models.MoodState
import com.gkatidis.daymaker.models.UserProfile
import kotlinx.coroutines.flow.*
import java.util.*

private val Context.dataStore by preferencesDataStore(name = "daymaker_prefs")

class ProfileRepository(private val context: Context) {

    private val gson = Gson()

    private object Keys {
        val PROFILE        = stringPreferencesKey("profile")
        val COMPLIMENTS    = stringPreferencesKey("compliments")
        val API_KEY        = stringPreferencesKey("api_key")
        val TODAY_MOOD     = stringPreferencesKey("today_mood")
        val MOOD_DATE      = longPreferencesKey("mood_date")
    }

    val profileFlow: Flow<UserProfile> = context.dataStore.data.map { prefs ->
        prefs[Keys.PROFILE]?.let { gson.fromJson(it, UserProfile::class.java) } ?: UserProfile()
    }

    val complimentsFlow: Flow<List<Compliment>> = context.dataStore.data.map { prefs ->
        prefs[Keys.COMPLIMENTS]?.let {
            val type = object : TypeToken<List<Compliment>>() {}.type
            gson.fromJson<List<Compliment>>(it, type) ?: emptyList()
        } ?: emptyList()
    }

    val apiKeyFlow: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[Keys.API_KEY] ?: ""
    }

    val todayMoodFlow: Flow<MoodState?> = context.dataStore.data.map { prefs ->
        val date = prefs[Keys.MOOD_DATE] ?: 0L
        if (isToday(date)) {
            prefs[Keys.TODAY_MOOD]?.let { MoodState.valueOf(it) }
        } else null
    }

    suspend fun saveProfile(profile: UserProfile) {
        context.dataStore.edit { it[Keys.PROFILE] = gson.toJson(profile) }
    }

    suspend fun saveApiKey(key: String) {
        context.dataStore.edit { it[Keys.API_KEY] = key }
    }

    suspend fun saveTodayMood(mood: MoodState) {
        context.dataStore.edit {
            it[Keys.TODAY_MOOD] = mood.name
            it[Keys.MOOD_DATE]  = System.currentTimeMillis()
        }
    }

    suspend fun saveCompliment(compliment: Compliment) {
        val current = complimentsFlow.first().toMutableList()
        current.add(0, compliment)
        context.dataStore.edit { it[Keys.COMPLIMENTS] = gson.toJson(current) }
    }

    suspend fun updateCompliment(updated: Compliment) {
        val list = complimentsFlow.first().map { if (it.id == updated.id) updated else it }
        context.dataStore.edit { it[Keys.COMPLIMENTS] = gson.toJson(list) }
    }

    suspend fun toggleFavorite(id: String) {
        val list = complimentsFlow.first().map {
            if (it.id == id) it.copy(isFavorite = !it.isFavorite) else it
        }
        context.dataStore.edit { it[Keys.COMPLIMENTS] = gson.toJson(list) }
    }

    suspend fun saveJournalNote(id: String, note: String) {
        val list = complimentsFlow.first().map {
            if (it.id == id) it.copy(journalNote = note) else it
        }
        context.dataStore.edit { it[Keys.COMPLIMENTS] = gson.toJson(list) }
    }

    suspend fun markRead(id: String) {
        val list = complimentsFlow.first().map {
            if (it.id == id) it.copy(isRead = true) else it
        }
        context.dataStore.edit { it[Keys.COMPLIMENTS] = gson.toJson(list) }
    }

    suspend fun resetAll() {
        context.dataStore.edit { it.clear() }
        StreakRepository(context).reset()
        BoostRepository(context).reset()
    }

    fun todaysCompliments(all: List<Compliment>): List<Compliment> =
        all.filter { isToday(it.date) }

    private fun isToday(time: Long): Boolean {
        val cal = Calendar.getInstance()
        val today = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        return time >= today
    }

    val isSunday: Boolean get() = Calendar.getInstance().get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY
    val isFirstOfMonth: Boolean get() = Calendar.getInstance().get(Calendar.DAY_OF_MONTH) == 1
}

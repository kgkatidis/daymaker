// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.viewmodels

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.gkatidis.daymaker.models.*
import com.gkatidis.daymaker.services.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.Calendar

class MainViewModel(app: Application) : AndroidViewModel(app) {

    private val profileRepo = ProfileRepository(app)
    private val claudeRepo  = ClaudeRepository()
    private val streakRepo  = StreakRepository(app)
    private val boostRepo   = BoostRepository(app)
    private val notifHelper = NotificationHelper(app)

    val profile     = profileRepo.profileFlow.stateIn(viewModelScope, SharingStarted.Eagerly, UserProfile())
    val compliments = profileRepo.complimentsFlow.stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())
    val apiKey      = profileRepo.apiKeyFlow.stateIn(viewModelScope, SharingStarted.Eagerly, "")
    val todayMood   = profileRepo.todayMoodFlow.stateIn(viewModelScope, SharingStarted.Eagerly, null)
    val streak      = streakRepo.streakFlow.stateIn(viewModelScope, SharingStarted.Eagerly, StreakRepository.StreakData(0,0,0))
    val boostRemaining = boostRepo.remainingFlow.stateIn(viewModelScope, SharingStarted.Eagerly, 3)

    private val _loadingSlots = MutableStateFlow<Set<ComplimentSlot>>(emptySet())
    val loadingSlots = _loadingSlots.asStateFlow()

    private val _loadingSpecial = MutableStateFlow(false)
    val loadingSpecial = _loadingSpecial.asStateFlow()

    private val _newSlots = MutableStateFlow<Set<ComplimentSlot>>(emptySet())
    val newSlots = _newSlots.asStateFlow()

    private val _toastMessage = MutableSharedFlow<String>()
    val toastMessage = _toastMessage.asSharedFlow()

    val currentHour: Int get() = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    val isSunday: Boolean get() = profileRepo.isSunday
    val isFirstOfMonth: Boolean get() = profileRepo.isFirstOfMonth

    fun onAppStart() {
        viewModelScope.launch {
            streakRepo.recordToday()
            autoGenerateAvailable()
        }
    }

    fun setMood(mood: MoodState) {
        viewModelScope.launch {
            profileRepo.saveTodayMood(mood)
            autoGenerateAvailable()
        }
    }

    fun generateCompliment(slot: ComplimentSlot) {
        val mood = todayMood.value
        viewModelScope.launch {
            _loadingSlots.value = _loadingSlots.value + slot
            try {
                val key = apiKey.value
                val text = if (key.isNotEmpty()) {
                    claudeRepo.generateCompliment(profile.value, slot, mood, key)
                } else {
                    claudeRepo.fallbackCompliment(profile.value, slot, mood)
                }
                val c = Compliment(text = text, slot = slot, mood = mood)
                profileRepo.saveCompliment(c)
                _newSlots.value = _newSlots.value + slot
            } catch (e: Exception) {
                val text = claudeRepo.fallbackCompliment(profile.value, slot, mood)
                val c = Compliment(text = text, slot = slot, mood = mood)
                profileRepo.saveCompliment(c)
                _newSlots.value = _newSlots.value + slot
            } finally {
                _loadingSlots.value = _loadingSlots.value - slot
            }
        }
    }

    fun generateSoulLetter() {
        viewModelScope.launch {
            _loadingSpecial.value = true
            try {
                val text = claudeRepo.generateSoulLetter(profile.value, apiKey.value)
                profileRepo.saveCompliment(Compliment(text = text, slot = ComplimentSlot.EVENING, isSoulLetter = true))
            } catch (e: Exception) {
                val name = profile.value.name.ifEmpty { "" }
                val fallback = "Αυτή η εβδομάδα σε είδε να δίνεις τον καλύτερό σου εαυτό. Ό,τι κι αν ένιωσες, ήσουν παρών/παρούσα. Και αυτό μετράει. — DayMaker"
                profileRepo.saveCompliment(Compliment(text = fallback, slot = ComplimentSlot.EVENING, isSoulLetter = true))
            } finally {
                _loadingSpecial.value = false
            }
        }
    }

    fun generateMonthlyLetter() {
        viewModelScope.launch {
            _loadingSpecial.value = true
            try {
                val text = claudeRepo.generateMonthlyLetter(profile.value, apiKey.value)
                profileRepo.saveCompliment(Compliment(text = text, slot = ComplimentSlot.EVENING, isMonthlyLetter = true))
            } catch (e: Exception) {
                _loadingSpecial.value = false
            } finally {
                _loadingSpecial.value = false
            }
        }
    }

    fun generateBoost(onResult: (Compliment) -> Unit) {
        viewModelScope.launch {
            if (!boostRepo.canBoost()) return@launch
            boostRepo.useBoost()
            try {
                val text = claudeRepo.generateBoost(profile.value, apiKey.value)
                val c = Compliment(text = text, slot = ComplimentSlot.MORNING, mood = todayMood.value)
                profileRepo.saveCompliment(c)
                onResult(c)
            } catch (e: Exception) {
                val name = profile.value.name.ifEmpty { "φίλε" }
                val text = "$name, αυτή τη στιγμή — ακριβώς τώρα — να ξέρεις ότι αξίζεις. Όχι αύριο. Τώρα, ακριβώς όπως είσαι."
                val c = Compliment(text = text, slot = ComplimentSlot.MORNING, mood = todayMood.value)
                profileRepo.saveCompliment(c)
                onResult(c)
            }
        }
    }

    fun markRead(id: String) = viewModelScope.launch { profileRepo.markRead(id) }
    fun toggleFavorite(id: String) = viewModelScope.launch { profileRepo.toggleFavorite(id) }
    fun saveJournalNote(id: String, note: String) = viewModelScope.launch { profileRepo.saveJournalNote(id, note) }
    fun saveProfile(p: UserProfile) = viewModelScope.launch {
        profileRepo.saveProfile(p)
        notifHelper.scheduleAll(p.name)
    }
    fun saveApiKey(key: String) = viewModelScope.launch { profileRepo.saveApiKey(key) }
    fun resetAll() = viewModelScope.launch {
        notifHelper.cancelAll()
        profileRepo.resetAll()
    }

    fun todayCompliments(): List<Compliment> = profileRepo.todaysCompliments(compliments.value)
    fun favorites(): List<Compliment> = compliments.value.filter { it.isFavorite }

    private fun autoGenerateAvailable() {
        val todays = profileRepo.todaysCompliments(compliments.value)
        val generatedSlots = todays.filter { !it.isSoulLetter && !it.isMonthlyLetter }.map { it.slot }.toSet()
        ComplimentSlot.values().forEach { slot ->
            if (currentHour >= slot.hour && slot !in generatedSlots) {
                generateCompliment(slot)
            }
        }
    }

    fun scheduleNotifications() {
        notifHelper.scheduleAll(profile.value.name)
    }
}

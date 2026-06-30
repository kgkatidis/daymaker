// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.services

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.gkatidis.daymaker.MainActivity
import com.gkatidis.daymaker.models.ComplimentSlot
import java.util.*

const val CHANNEL_ID = "daymaker_channel"

class NotificationHelper(private val context: Context) {

    init { createChannel() }

    private fun createChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID, "DayMaker Μηνύματα",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Εξατομικευμένα ημερήσια μηνύματα"
            enableVibration(true)
        }
        context.getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    fun scheduleAll(userName: String) {
        ComplimentSlot.values().forEach { slot ->
            scheduleSlot(slot, userName)
        }
    }

    private fun scheduleSlot(slot: ComplimentSlot, userName: String) {
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, slot.hour)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            if (timeInMillis <= System.currentTimeMillis()) add(Calendar.DAY_OF_YEAR, 1)
        }

        val intent = Intent(context, NotificationReceiver::class.java).apply {
            putExtra("slot", slot.name)
            putExtra("userName", userName)
        }
        val pi = PendingIntent.getBroadcast(
            context, slot.ordinal, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmMgr = context.getSystemService(AlarmManager::class.java)
        alarmMgr.setRepeating(AlarmManager.RTC_WAKEUP, cal.timeInMillis, AlarmManager.INTERVAL_DAY, pi)
    }

    fun cancelAll() {
        val alarmMgr = context.getSystemService(AlarmManager::class.java)
        ComplimentSlot.values().forEach { slot ->
            val intent = Intent(context, NotificationReceiver::class.java)
            val pi = PendingIntent.getBroadcast(
                context, slot.ordinal, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmMgr.cancel(pi)
        }
    }

    fun showNotification(slotName: String, userName: String) {
        val slot = ComplimentSlot.valueOf(slotName)
        val name = userName.ifEmpty { "σε" }
        val body = when (slot) {
            ComplimentSlot.MORNING    -> "Καλημέρα $name! Ένα μήνυμα ειδικά για σένα ✨"
            ComplimentSlot.MID_MORNING -> "Μια στιγμή γεμάτη θετική ενέργεια για τον $name 🌟"
            ComplimentSlot.AFTERNOON  -> "Θυμίσου ποιος είσαι, $name. Άνοιξε να δεις 💫"
            ComplimentSlot.EVENING    -> "Πριν τελειώσει η μέρα — ένα μήνυμα μόνο για σένα 🌙"
        }

        val tapIntent = PendingIntent.getActivity(
            context, 0,
            Intent(context, MainActivity::class.java).apply { flags = Intent.FLAG_ACTIVITY_SINGLE_TOP },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("${slot.emoji} ${slot.displayName}")
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(tapIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        context.getSystemService(NotificationManager::class.java)
            .notify(slot.ordinal, notification)
    }
}

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val slot = intent.getStringExtra("slot") ?: return
        val user = intent.getStringExtra("userName") ?: ""
        NotificationHelper(context).showNotification(slot, user)
    }
}

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Re-schedule on reboot — ViewModel will handle the actual data
            // Notifications will be re-scheduled when user opens the app
        }
    }
}

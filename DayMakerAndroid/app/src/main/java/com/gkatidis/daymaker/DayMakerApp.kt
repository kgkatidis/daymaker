// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import com.gkatidis.daymaker.services.CHANNEL_ID

class DayMakerApp : Application() {
    override fun onCreate() {
        super.onCreate()
        val channel = NotificationChannel(
            CHANNEL_ID, "DayMaker Μηνύματα",
            NotificationManager.IMPORTANCE_HIGH
        ).apply { description = "Εξατομικευμένα ημερήσια μηνύματα" }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }
}

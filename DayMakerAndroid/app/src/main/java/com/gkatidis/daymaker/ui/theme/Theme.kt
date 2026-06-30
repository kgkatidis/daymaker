// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val Purple80   = Color(0xFFD0BCFF)
val Purple40   = Color(0xFF6650A4)
val PurpleGrey = Color(0xFF625B71)

// Slot gradients
val MorningStart   = Color(0xFFFF6B6B)
val MorningEnd     = Color(0xFFFFE66D)
val MidMorningStart = Color(0xFF4FACFE)
val MidMorningEnd  = Color(0xFF00F2FE)
val AfternoonStart = Color(0xFF43E97B)
val AfternoonEnd   = Color(0xFF38F9D7)
val EveningStart   = Color(0xFF667EEA)
val EveningEnd     = Color(0xFF764BA2)
val BoostStart     = Color(0xFF4776E6)
val BoostEnd       = Color(0xFF8E54E9)
val SoulStart      = Color(0xFF1a1a2e)
val SoulEnd        = Color(0xFF0f3460)
val MonthlyStart   = Color(0xFF0f0c29)
val MonthlyEnd     = Color(0xFF302b63)
val FavStart       = Color(0xFFf093fb)
val FavEnd         = Color(0xFFf5576c)

private val DarkColors = darkColorScheme(
    primary = Purple80,
    secondary = PurpleGrey,
    background = Color(0xFF1C1B1F)
)

private val LightColors = lightColorScheme(
    primary = Purple40,
    secondary = PurpleGrey,
)

@Composable
fun DayMakerTheme(darkTheme: Boolean = false, content: @Composable () -> Unit) {
    val colors = if (darkTheme) DarkColors else LightColors
    MaterialTheme(colorScheme = colors, content = content)
}

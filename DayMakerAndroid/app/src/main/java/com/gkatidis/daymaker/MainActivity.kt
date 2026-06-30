// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.*
import androidx.lifecycle.viewmodel.compose.viewModel
import com.gkatidis.daymaker.ui.screens.*
import com.gkatidis.daymaker.ui.theme.DayMakerTheme
import com.gkatidis.daymaker.viewmodels.MainViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            DayMakerTheme {
                DayMakerNavHost()
            }
        }
    }
}

sealed class Screen {
    object Onboarding : Screen()
    object Home : Screen()
    object Boost : Screen()
    object History : Screen()
    object Favorites : Screen()
    object Profile : Screen()
}

@Composable
fun DayMakerNavHost() {
    val vm: MainViewModel = viewModel()
    val profile by vm.profile.collectAsState()
    var screen by remember { mutableStateOf<Screen>(if (profile.isOnboardingComplete) Screen.Home else Screen.Onboarding) }

    LaunchedEffect(profile.isOnboardingComplete) {
        if (profile.isOnboardingComplete && screen == Screen.Onboarding) {
            screen = Screen.Home
        }
    }

    LaunchedEffect(Unit) { if (profile.isOnboardingComplete) vm.onAppStart() }

    when (screen) {
        is Screen.Onboarding -> OnboardingScreen(vm) {
            vm.onAppStart()
            screen = Screen.Home
        }
        is Screen.Home -> HomeScreen(
            vm = vm,
            onBoost = { screen = Screen.Boost },
            onVault = { screen = Screen.Favorites },
            onHistory = { screen = Screen.History },
            onProfile = { screen = Screen.Profile }
        )
        is Screen.Boost -> BoostScreen(vm) { screen = Screen.Home }
        is Screen.History -> HistoryScreen(vm) { screen = Screen.Home }
        is Screen.Favorites -> FavoritesScreen(vm) { screen = Screen.Home }
        is Screen.Profile -> ProfileScreen(vm, onBack = { screen = Screen.Home }, onReset = { screen = Screen.Onboarding })
    }
}

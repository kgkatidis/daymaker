// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.ui.screens

import android.content.Intent
import android.speech.tts.TextToSpeech
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.*
import androidx.compose.foundation.shape.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.*
import androidx.compose.ui.platform.*
import androidx.compose.ui.text.font.*
import androidx.compose.ui.text.style.*
import androidx.compose.ui.unit.*
import com.gkatidis.daymaker.models.*
import com.gkatidis.daymaker.ui.components.*
import com.gkatidis.daymaker.ui.theme.*
import com.gkatidis.daymaker.viewmodels.MainViewModel
import java.util.Locale

// ──────────────────────────────────────────────
// ONBOARDING
// ──────────────────────────────────────────────

@Composable
fun OnboardingScreen(vm: MainViewModel, onDone: () -> Unit) {
    var showIntro by remember { mutableStateOf(true) }
    var step by remember { mutableIntStateOf(0) }
    var answer by remember { mutableStateOf("") }
    var apiKey by remember { mutableStateOf("") }
    var showApiKey by remember { mutableStateOf(false) }
    val answers = remember { mutableStateMapOf<String, String>() }
    val q = ONBOARDING_QUESTIONS[step]

    Box(modifier = Modifier.fillMaxSize().background(Brush.linearGradient(listOf(EveningStart, EveningEnd)))) {
        if (showIntro) {
            Column(modifier = Modifier.fillMaxSize().padding(28.dp), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
                Text("☀️", fontSize = 80.sp)
                Spacer(Modifier.height(16.dp))
                Text("DayMaker", fontSize = 40.sp, fontWeight = FontWeight.Bold, color = Color.White)
                Text("Η εφαρμογή που φτιάχνει τη μέρα σου", fontSize = 16.sp, color = Color.White.copy(0.85f), textAlign = TextAlign.Center)
                Spacer(Modifier.height(32.dp))
                Text("Πριν ξεκινήσουμε, θέλω να σε γνωρίσω καλά. Θα σου κάνω μερικές ερωτήσεις — απάντα ειλικρινά.",
                    color = Color.White.copy(0.8f), textAlign = TextAlign.Center, fontSize = 15.sp)
                Spacer(Modifier.height(40.dp))
                Button(onClick = { showIntro = false }, modifier = Modifier.fillMaxWidth().height(56.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.White)) {
                    Text("Ας ξεκινήσουμε →", color = Purple40, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
            }
        } else if (showApiKey) {
            Column(modifier = Modifier.fillMaxSize().padding(28.dp), verticalArrangement = Arrangement.Center) {
                Icon(Icons.Filled.Key, null, tint = Color.White, modifier = Modifier.size(50.dp))
                Spacer(Modifier.height(16.dp))
                Text("Ένα τελευταίο βήμα", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Color.White)
                Spacer(Modifier.height(8.dp))
                Text("Χρειάζομαι Claude API key για εξατομικευμένα μηνύματα. Το βρίσκεις στο console.anthropic.com", color = Color.White.copy(0.8f))
                Spacer(Modifier.height(24.dp))
                OutlinedTextField(value = apiKey, onValueChange = { apiKey = it }, placeholder = { Text("sk-ant-...") },
                    modifier = Modifier.fillMaxWidth(), colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.White, unfocusedTextColor = Color.White,
                        focusedBorderColor = Color.White, unfocusedBorderColor = Color.White.copy(0.5f)
                    ))
                Spacer(Modifier.height(28.dp))
                Button(onClick = { finish(vm, answers, apiKey, onDone) }, modifier = Modifier.fillMaxWidth().height(56.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.White)) {
                    Text("Ξεκινάμε! 🚀", color = Purple40, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
                Spacer(Modifier.height(12.dp))
                TextButton(onClick = { finish(vm, answers, apiKey, onDone) }, modifier = Modifier.fillMaxWidth()) {
                    Text("Παράλειψη προς το παρόν", color = Color.White.copy(0.7f))
                }
            }
        } else {
            Column(modifier = Modifier.fillMaxSize().padding(horizontal = 28.dp)) {
                Spacer(Modifier.height(60.dp))
                // Progress
                LinearProgressIndicator(progress = { step.toFloat() / ONBOARDING_QUESTIONS.size },
                    modifier = Modifier.fillMaxWidth(), color = Color.White, trackColor = Color.White.copy(0.3f))
                Text("${step + 1} / ${ONBOARDING_QUESTIONS.size}", color = Color.White.copy(0.7f), fontSize = 12.sp, modifier = Modifier.padding(top = 4.dp))
                Spacer(Modifier.height(32.dp))
                Text(q.emoji, fontSize = 52.sp)
                Spacer(Modifier.height(12.dp))
                Text(q.question, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
                Spacer(Modifier.height(6.dp))
                Text(q.hint, fontSize = 13.sp, color = Color.White.copy(0.7f))
                Spacer(Modifier.height(20.dp))
                OutlinedTextField(value = answer, onValueChange = { answer = it }, placeholder = { Text(q.placeholder, color = Color.White.copy(0.4f)) },
                    modifier = Modifier.fillMaxWidth().heightIn(min = 120.dp), maxLines = 5,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.White, unfocusedTextColor = Color.White,
                        focusedBorderColor = Color.White.copy(0.7f), unfocusedBorderColor = Color.White.copy(0.4f),
                        focusedContainerColor = Color.White.copy(0.1f), unfocusedContainerColor = Color.White.copy(0.1f)
                    ))
                Spacer(Modifier.weight(1f))
                Button(onClick = {
                    if (answer.isBlank()) return@Button
                    answers[q.field] = answer.trim()
                    answer = ""
                    if (step < ONBOARDING_QUESTIONS.size - 1) step++ else showApiKey = true
                }, modifier = Modifier.fillMaxWidth().height(56.dp).padding(bottom = 8.dp),
                    enabled = answer.isNotBlank(),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White)) {
                    Text(if (step < ONBOARDING_QUESTIONS.size - 1) "Επόμενο →" else "Ολοκλήρωση ✓", color = Purple40, fontWeight = FontWeight.Bold)
                }
                Spacer(Modifier.height(36.dp))
            }
        }
    }
}

private fun finish(vm: MainViewModel, answers: Map<String, String>, apiKey: String, onDone: () -> Unit) {
    val profile = UserProfile(
        name = answers["name"] ?: "", age = answers["age"] ?: "", profession = answers["profession"] ?: "",
        proudestAchievement = answers["proudestAchievement"] ?: "", passionsAndHobbies = answers["passionsAndHobbies"] ?: "",
        personalityTrait = answers["personalityTrait"] ?: "", goalsNextYear = answers["goalsNextYear"] ?: "",
        frequentCompliments = answers["frequentCompliments"] ?: "", recentChallenge = answers["recentChallenge"] ?: "",
        whatMakesUnique = answers["whatMakesUnique"] ?: "", physicalFeatureLove = answers["physicalFeatureLove"] ?: "",
        morningRoutine = answers["morningRoutine"] ?: "", relationshipStatus = answers["relationshipStatus"] ?: "",
        lifePhilosophy = answers["lifePhilosophy"] ?: "", isOnboardingComplete = true
    )
    vm.saveProfile(profile)
    if (apiKey.isNotBlank()) vm.saveApiKey(apiKey)
    onDone()
}

// ──────────────────────────────────────────────
// HOME
// ──────────────────────────────────────────────

@Composable
fun HomeScreen(vm: MainViewModel, onBoost: () -> Unit, onVault: () -> Unit, onHistory: () -> Unit, onProfile: () -> Unit) {
    val profile by vm.profile.collectAsState()
    val compliments by vm.compliments.collectAsState()
    val todayMood by vm.todayMood.collectAsState()
    val loadingSlots by vm.loadingSlots.collectAsState()
    val newSlots by vm.newSlots.collectAsState()
    val streak by vm.streak.collectAsState()
    val boostRemaining by vm.boostRemaining.collectAsState()
    val loadingSpecial by vm.loadingSpecial.collectAsState()
    val streakRepo = remember { com.gkatidis.daymaker.services.StreakRepository(androidx.compose.ui.platform.LocalContext.current) }

    val todays = vm.todayCompliments()
    val generatedSlots = todays.filter { !it.isSoulLetter && !it.isMonthlyLetter }.associateBy { it.slot }
    val soulLetter = todays.firstOrNull { it.isSoulLetter }
    val monthlyLetter = todays.firstOrNull { it.isMonthlyLetter }

    var showSoulLetter by remember { mutableStateOf<Compliment?>(null) }
    var showMonthlyLetter by remember { mutableStateOf<Compliment?>(null) }
    var journalTarget by remember { mutableStateOf<Compliment?>(null) }

    val context = LocalContext.current
    var isSpeaking by remember { mutableStateOf(false) }
    val tts = remember {
        var t: TextToSpeech? = null
        t = TextToSpeech(context) { t?.language = Locale("el", "GR") }; t
    }
    DisposableEffect(Unit) { onDispose { tts.shutdown() } }

    val hour = vm.currentHour
    val greeting = when (hour) {
        in 5..11  -> "Καλημέρα, ${profile.name} 🌅"
        in 12..16 -> "Καλό μεσημέρι, ${profile.name} ☀️"
        in 17..20 -> "Καλό απόγευμα, ${profile.name} 🌤"
        else      -> "Καλό βράδυ, ${profile.name} 🌙"
    }

    val score = run {
        var s = 0
        if (todayMood != null) s += 20
        if (streak.current > 0) s += 20
        val readCount = todays.count { it.isRead && !it.isSoulLetter && !it.isMonthlyLetter }
        s += minOf(readCount, 4) * 10
        if (todays.any { it.journalNote != null }) s += 20
        s
    }
    val scoreBreakdown = linkedMapOf(
        "Mood check-in"          to Pair(todayMood != null, 20),
        "Streak ενεργό"          to Pair(streak.current > 0, 20),
        "Μηνύματα διαβάστηκαν"  to Pair(todays.any { it.isRead && !it.isSoulLetter }, todays.count { it.isRead && !it.isSoulLetter && !it.isMonthlyLetter } * 10),
        "Journal σημείωση"       to Pair(todays.any { it.journalNote != null }, 20)
    )

    Scaffold(
        floatingActionButton = {
            FloatingActionButton(
                onClick = onBoost,
                containerColor = if (boostRemaining > 0) Color(0xFF8E54E9) else Color.Gray,
                contentColor = Color.White
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("⚡️", fontSize = 20.sp)
                    Text("$boostRemaining", fontSize = 9.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    ) { padding ->
        LazyColumn(modifier = Modifier.fillMaxSize().padding(padding), contentPadding = PaddingValues(bottom = 80.dp)) {
            // Header
            item {
                Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("☀️ DayMaker", fontSize = 22.sp, fontWeight = FontWeight.Bold)
                        Text(greeting, fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    IconButton(onClick = onVault) { Icon(Icons.Filled.Favorite, null, tint = Color(0xFFFF6B6B)) }
                    IconButton(onClick = onHistory) { Icon(Icons.Filled.History, null, tint = Purple40) }
                    IconButton(onClick = onProfile) { Icon(Icons.Filled.AccountCircle, null, tint = Purple40) }
                }
            }
            item { Spacer(Modifier.height(4.dp)) }
            item { StreakBanner(streak.current, streak.longest, streak.total, streakRepo) }
            item { Spacer(Modifier.height(8.dp)) }
            item { DayScoreRing(score, scoreBreakdown) }
            item { Spacer(Modifier.height(8.dp)) }

            // Mood
            item {
                if (todayMood == null) {
                    MoodCheckIn { vm.setMood(it) }
                } else {
                    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(14.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                        Row(modifier = Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                            Text(todayMood!!.emoji, fontSize = 22.sp)
                            Column {
                                Text("Σήμερα: ${todayMood!!.label}", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                Text("Τα μηνύματά σου είναι προσαρμοσμένα.", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                        }
                    }
                }
            }
            item { Spacer(Modifier.height(8.dp)) }

            // Monthly letter
            if (vm.isFirstOfMonth) {
                item {
                    SpecialLetterCard("Μηνιαία Επιστολή 🗓️", monthlyLetter, loadingSpecial,
                        onOpen = { vm.generateMonthlyLetter() },
                        onTap = { showMonthlyLetter = monthlyLetter }
                    )
                    Spacer(Modifier.height(8.dp))
                }
            }
            // Soul letter
            if (vm.isSunday) {
                item {
                    SpecialLetterCard("Soul Letter ✉️", soulLetter, loadingSpecial,
                        onOpen = { vm.generateSoulLetter() },
                        onTap = { showSoulLetter = soulLetter }
                    )
                    Spacer(Modifier.height(8.dp))
                }
            }

            // Today's compliments
            item { Text("Σήμερα", fontWeight = FontWeight.Bold, modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp)) }

            items(ComplimentSlot.values()) { slot ->
                val existing = generatedSlots[slot]
                val isLoading = slot in loadingSlots
                val isAvailable = hour >= slot.hour
                val isNew = slot in newSlots

                when {
                    isLoading -> LoadingCard(slot)
                    existing != null -> ComplimentCard(
                        compliment = existing, isNew = isNew,
                        onFavorite = { vm.toggleFavorite(existing.id) },
                        onJournal = { journalTarget = existing },
                        onShare = {
                            val intent = Intent(Intent.ACTION_SEND).apply {
                                type = "text/plain"; putExtra(Intent.EXTRA_TEXT, existing.text + "\n\n— DayMaker")
                            }
                            context.startActivity(Intent.createChooser(intent, "Κοινοποίηση"))
                        },
                        onSpeak = {
                            if (isSpeaking) { tts.stop(); isSpeaking = false }
                            else { tts.speak(existing.text, TextToSpeech.QUEUE_FLUSH, null, null); isSpeaking = true }
                        },
                        isSpeaking = isSpeaking
                    )
                    else -> LockedSlotCard(slot, isAvailable) { vm.generateCompliment(slot) }
                }
                Spacer(Modifier.height(10.dp))
            }

            item {
                Text("© 2026 Konstantinos Gkatidis · DayMaker", fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(0.5f),
                    modifier = Modifier.fillMaxWidth().padding(top = 12.dp), textAlign = TextAlign.Center)
            }
        }
    }

    // Dialogs
    showSoulLetter?.let { SpecialLetterDialog(it, "Soul Letter ✉️") { showSoulLetter = null } }
    showMonthlyLetter?.let { SpecialLetterDialog(it, "Μηνιαία Επιστολή 🗓️") { showMonthlyLetter = null } }
    journalTarget?.let { c ->
        JournalDialog(c, onDismiss = { journalTarget = null }) { note ->
            vm.saveJournalNote(c.id, note); journalTarget = null
        }
    }
}

@Composable
fun SpecialLetterCard(title: String, existing: Compliment?, loading: Boolean, onOpen: () -> Unit, onTap: () -> Unit) {
    if (loading && existing == null) {
        Card(modifier = Modifier.fillMaxWidth().height(90.dp), shape = RoundedCornerShape(20.dp)) {
            Box(modifier = Modifier.background(Brush.linearGradient(listOf(SoulStart, SoulEnd))).fillMaxSize(), contentAlignment = Alignment.Center) {
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(22.dp), strokeWidth = 2.dp)
                    Text("Ετοιμάζεται...", color = Color.White.copy(0.8f))
                }
            }
        }
    } else if (existing != null) {
        Card(modifier = Modifier.fillMaxWidth().clickable(onClick = onTap), shape = RoundedCornerShape(20.dp)) {
            Box(modifier = Modifier.background(Brush.linearGradient(listOf(SoulStart, SoulEnd))).fillMaxWidth().padding(18.dp)) {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(title, color = Color.White.copy(0.7f), fontSize = 12.sp)
                    Text(existing.text, color = Color.White.copy(0.9f), maxLines = 2, overflow = TextOverflow.Ellipsis, fontSize = 14.sp)
                }
                Text("Άνοιγμα →", color = Color.White.copy(0.5f), fontSize = 11.sp, modifier = Modifier.align(Alignment.BottomEnd))
            }
        }
    } else {
        Button(onClick = onOpen, modifier = Modifier.fillMaxWidth().height(52.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1a1a2e))) {
            Text("Άνοιξε $title", color = Color.White, fontWeight = FontWeight.SemiBold)
        }
    }
}

@Composable
fun SpecialLetterDialog(compliment: Compliment, title: String, onDismiss: () -> Unit) {
    AlertDialog(onDismissRequest = onDismiss, confirmButton = { TextButton(onClick = onDismiss) { Text("Κλείσιμο") } },
        title = { Text(title, fontWeight = FontWeight.Bold) },
        text = { Text(compliment.text, lineHeight = 22.sp) })
}

@Composable
fun JournalDialog(compliment: Compliment, onDismiss: () -> Unit, onSave: (String) -> Unit) {
    var note by remember { mutableStateOf(compliment.journalNote ?: "") }
    AlertDialog(onDismissRequest = onDismiss,
        confirmButton = { TextButton(onClick = { if (note.isNotBlank()) onSave(note) }) { Text("Αποθήκευση") } },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Ακύρωση") } },
        title = { Text("Σημείωμα ✏️") },
        text = {
            OutlinedTextField(value = note, onValueChange = { note = it }, placeholder = { Text("Πώς σε έκανε να νιώσεις;") },
                modifier = Modifier.fillMaxWidth().heightIn(min = 120.dp), maxLines = 6)
        })
}

// ──────────────────────────────────────────────
// BOOST
// ──────────────────────────────────────────────

@Composable
fun BoostScreen(vm: MainViewModel, onDismiss: () -> Unit) {
    var compliment by remember { mutableStateOf<Compliment?>(null) }
    var loading by remember { mutableStateOf(true) }
    val boostRemaining by vm.boostRemaining.collectAsState()
    val context = LocalContext.current

    LaunchedEffect(Unit) {
        vm.generateBoost { c -> compliment = c; loading = false }
    }

    Box(modifier = Modifier.fillMaxSize().background(Brush.linearGradient(listOf(BoostStart, BoostEnd))), contentAlignment = Alignment.Center) {
        Column(modifier = Modifier.padding(28.dp).fillMaxSize(), horizontalAlignment = Alignment.CenterHorizontally) {
            Row(modifier = Modifier.fillMaxWidth()) {
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Filled.Close, null, tint = Color.White.copy(0.7f))
                }
                Spacer(Modifier.weight(1f))
                repeat(com.gkatidis.daymaker.services.BoostRepository(context).MAX_PER_DAY) { i ->
                    Box(modifier = Modifier.size(8.dp).clip(CircleShape)
                        .background(if (i < (3 - boostRemaining)) Color.White.copy(0.35f) else Color.White))
                    Spacer(Modifier.width(4.dp))
                }
            }
            Spacer(Modifier.weight(1f))
            Text("⚡️", fontSize = 64.sp)
            Spacer(Modifier.height(12.dp))
            Text("Instant Boost", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color.White)
            Spacer(Modifier.height(24.dp))
            if (loading) {
                CircularProgressIndicator(color = Color.White)
                Spacer(Modifier.height(10.dp))
                Text("Ετοιμάζω κάτι ξεχωριστό...", color = Color.White.copy(0.75f))
            } else {
                compliment?.let { c ->
                    TypewriterText(c.text, style = MaterialTheme.typography.bodyLarge, color = Color.White, modifier = Modifier.padding(horizontal = 8.dp))
                    Spacer(Modifier.height(28.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        Button(onClick = {
                            val intent = Intent(Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(Intent.EXTRA_TEXT, c.text + "\n\n— DayMaker Boost") }
                            context.startActivity(Intent.createChooser(intent, "Κοινοποίηση"))
                        }, colors = ButtonDefaults.buttonColors(containerColor = Color.White.copy(0.2f))) {
                            Icon(Icons.Filled.Share, null, tint = Color.White, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(6.dp)); Text("Κοινοποίηση", color = Color.White)
                        }
                    }
                }
            }
            Spacer(Modifier.weight(1f))
            Button(onClick = onDismiss, modifier = Modifier.fillMaxWidth().height(52.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.White.copy(0.2f))) {
                Text("Κλείσιμο", color = Color.White, fontWeight = FontWeight.SemiBold)
            }
            Spacer(Modifier.height(36.dp))
        }
    }
}

// ──────────────────────────────────────────────
// HISTORY
// ──────────────────────────────────────────────

@Composable
fun HistoryScreen(vm: MainViewModel, onBack: () -> Unit) {
    val compliments by vm.compliments.collectAsState()
    Scaffold(topBar = {
        TopAppBar(title = { Text("Ιστορικό") }, navigationIcon = {
            IconButton(onClick = onBack) { Icon(Icons.Filled.ArrowBack, null) }
        })
    }) { padding ->
        LazyColumn(modifier = Modifier.padding(padding), contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            items(compliments) { c ->
                ComplimentCard(c, compact = true, onFavorite = { vm.toggleFavorite(c.id) })
            }
            if (compliments.isEmpty()) {
                item {
                    Box(modifier = Modifier.fillMaxWidth().height(300.dp), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("✨", fontSize = 50.sp, modifier = Modifier.graphicsLayer(alpha = 0.4f))
                            Text("Δεν υπάρχουν μηνύματα ακόμα", color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
            }
        }
    }
}

// ──────────────────────────────────────────────
// FAVORITES
// ──────────────────────────────────────────────

@Composable
fun FavoritesScreen(vm: MainViewModel, onBack: () -> Unit) {
    val favorites = vm.favorites()
    Scaffold(topBar = {
        TopAppBar(title = { Text("Vault ❤️") }, navigationIcon = {
            IconButton(onClick = onBack) { Icon(Icons.Filled.ArrowBack, null) }
        })
    }) { padding ->
        LazyColumn(modifier = Modifier.padding(padding), contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            if (favorites.isEmpty()) {
                item {
                    Box(modifier = Modifier.fillMaxWidth().height(300.dp), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("❤️", fontSize = 50.sp, modifier = Modifier.graphicsLayer(alpha = 0.4f))
                            Text("Κανένα αγαπημένο ακόμα", color = MaterialTheme.colorScheme.onSurfaceVariant)
                            Text("Πάτα παρατεταμένα σε μήνυμα για να το αποθηκεύσεις.", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 40.dp))
                        }
                    }
                }
            } else {
                items(favorites) { c ->
                    ComplimentCard(c, onFavorite = { vm.toggleFavorite(c.id) })
                }
            }
        }
    }
}

// ──────────────────────────────────────────────
// PROFILE
// ──────────────────────────────────────────────

@Composable
fun ProfileScreen(vm: MainViewModel, onBack: () -> Unit, onReset: () -> Unit) {
    val profile by vm.profile.collectAsState()
    val streak by vm.streak.collectAsState()
    val compliments by vm.compliments.collectAsState()
    var editedName by remember(profile) { mutableStateOf(profile.name) }
    var editedApiKey by remember { mutableStateOf("") }
    var showReset by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) { vm.apiKey.collect { editedApiKey = it } }

    Scaffold(topBar = {
        TopAppBar(title = { Text("Προφίλ") }, navigationIcon = {
            IconButton(onClick = onBack) { Icon(Icons.Filled.ArrowBack, null) }
        }, actions = {
            TextButton(onClick = { vm.saveProfile(profile.copy(name = editedName)); vm.saveApiKey(editedApiKey) }) {
                Text("Αποθήκευση", color = Purple40, fontWeight = FontWeight.Bold)
            }
        })
    }) { padding ->
        LazyColumn(modifier = Modifier.padding(padding), contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            item {
                Card(colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("Προσωπικά στοιχεία", fontWeight = FontWeight.Bold)
                        OutlinedTextField(value = editedName, onValueChange = { editedName = it }, label = { Text("Όνομα") }, modifier = Modifier.fillMaxWidth())
                    }
                }
            }
            item {
                Card(colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Claude API Key", fontWeight = FontWeight.Bold)
                        OutlinedTextField(value = editedApiKey, onValueChange = { editedApiKey = it }, placeholder = { Text("sk-ant-...") }, modifier = Modifier.fillMaxWidth())
                        Text("console.anthropic.com → API Keys", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
            item {
                Card(colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Στατιστικά", fontWeight = FontWeight.Bold)
                        listOf("Συνολικά μηνύματα" to "${compliments.size}", "Streak ρεκόρ" to "${streak.longest} μέρες", "Αγαπημένα" to "${compliments.count { it.isFavorite }}").forEach { (k, v) ->
                            Row { Text(k, modifier = Modifier.weight(1f), color = MaterialTheme.colorScheme.onSurfaceVariant); Text(v, fontWeight = FontWeight.Bold) }
                        }
                    }
                }
            }
            item {
                Button(onClick = { showReset = true }, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)) {
                    Icon(Icons.Filled.Delete, null); Spacer(Modifier.width(8.dp)); Text("Επαναφορά εφαρμογής")
                }
            }
            item {
                Text("© 2026 Konstantinos Gkatidis · DayMaker\nPowered by Claude AI",
                    fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant.copy(0.5f), textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth().padding(top = 8.dp))
            }
        }
    }

    if (showReset) {
        AlertDialog(onDismissRequest = { showReset = false },
            title = { Text("Επαναφορά;") },
            text = { Text("Θα διαγραφούν όλα τα δεδομένα σου.") },
            confirmButton = { TextButton(onClick = { vm.resetAll(); showReset = false; onReset() }) { Text("Επαναφορά", color = MaterialTheme.colorScheme.error) } },
            dismissButton = { TextButton(onClick = { showReset = false }) { Text("Ακύρωση") } })
    }
}

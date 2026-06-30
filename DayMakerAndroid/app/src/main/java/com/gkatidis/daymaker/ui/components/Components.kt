// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

package com.gkatidis.daymaker.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gkatidis.daymaker.models.*
import com.gkatidis.daymaker.ui.theme.*
import kotlinx.coroutines.delay

fun slotGradient(slot: ComplimentSlot) = when (slot) {
    ComplimentSlot.MORNING     -> Brush.linearGradient(listOf(MorningStart, MorningEnd))
    ComplimentSlot.MID_MORNING -> Brush.linearGradient(listOf(MidMorningStart, MidMorningEnd))
    ComplimentSlot.AFTERNOON   -> Brush.linearGradient(listOf(AfternoonStart, AfternoonEnd))
    ComplimentSlot.EVENING     -> Brush.linearGradient(listOf(EveningStart, EveningEnd))
}

@Composable
fun TypewriterText(fullText: String, modifier: Modifier = Modifier, style: androidx.compose.ui.text.TextStyle = MaterialTheme.typography.bodyMedium, color: Color = Color.White) {
    var displayed by remember { mutableStateOf("") }
    LaunchedEffect(fullText) {
        displayed = ""
        fullText.forEachIndexed { i, c ->
            delay(18L)
            displayed = fullText.substring(0, i + 1)
        }
    }
    Text(displayed, modifier = modifier, style = style, color = color, lineHeight = 22.sp)
}

@Composable
fun ComplimentCard(
    compliment: Compliment,
    isNew: Boolean = false,
    compact: Boolean = false,
    onFavorite: () -> Unit = {},
    onJournal: () -> Unit = {},
    onShare: () -> Unit = {},
    onSpeak: () -> Unit = {},
    isSpeaking: Boolean = false
) {
    val gradient = if (compliment.isSoulLetter || compliment.isMonthlyLetter)
        Brush.linearGradient(listOf(SoulStart, SoulEnd))
    else slotGradient(compliment.slot)

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(if (compact) 14.dp else 20.dp),
        elevation = CardDefaults.cardElevation(8.dp)
    ) {
        Box(modifier = Modifier.background(gradient).fillMaxWidth()) {
            Column(modifier = Modifier.padding(if (compact) 14.dp else 20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                // Top bar
                Row(verticalAlignment = Alignment.CenterVertically) {
                    val label = when {
                        compliment.isMonthlyLetter -> "Μηνιαία Επιστολή"
                        compliment.isSoulLetter    -> "Soul Letter"
                        else -> "${compliment.slot.emoji} ${compliment.slot.displayName}"
                    }
                    Surface(color = Color.White.copy(alpha = 0.2f), shape = RoundedCornerShape(20.dp)) {
                        Text(label, color = Color.White.copy(alpha = 0.9f), fontSize = 11.sp, fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp))
                    }
                    compliment.mood?.let { mood ->
                        Spacer(Modifier.width(6.dp))
                        Surface(color = Color.White.copy(alpha = 0.15f), shape = RoundedCornerShape(20.dp)) {
                            Text(mood.emoji, fontSize = 12.sp, modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp))
                        }
                    }
                    Spacer(Modifier.weight(1f))
                    IconButton(onClick = onFavorite, modifier = Modifier.size(32.dp)) {
                        Icon(
                            if (compliment.isFavorite) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                            contentDescription = null,
                            tint = if (compliment.isFavorite) Color(0xFFFF6B6B) else Color.White.copy(alpha = 0.7f),
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }

                // Text
                if (isNew) {
                    TypewriterText(compliment.text, style = MaterialTheme.typography.bodyMedium, color = Color.White)
                } else {
                    Text(compliment.text, color = Color.White, style = MaterialTheme.typography.bodyMedium, lineHeight = 22.sp)
                }

                compliment.journalNote?.let { note ->
                    if (!compact) {
                        Row(verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            Icon(Icons.Filled.Edit, contentDescription = null, tint = Color.White.copy(alpha = 0.6f), modifier = Modifier.size(12.dp).padding(top = 2.dp))
                            Text(note, color = Color.White.copy(alpha = 0.75f), fontSize = 12.sp, lineHeight = 18.sp)
                        }
                    }
                }

                if (!compact) {
                    Row(modifier = Modifier.fillMaxWidth()) {
                        listOf(
                            Triple(if (isSpeaking) Icons.Filled.Stop else Icons.Filled.PlayArrow, if (isSpeaking) "Σταμάτα" else "Άκουσε", onSpeak),
                            Triple(Icons.Filled.Share, "Κοινοποίηση", onShare),
                            Triple(Icons.Filled.Edit, if (compliment.journalNote != null) "Σημείωση ✓" else "Σημείωση", onJournal)
                        ).forEachIndexed { i, (icon, label, action) ->
                            if (i > 0) Divider(modifier = Modifier.height(28.dp).width(1.dp), color = Color.White.copy(alpha = 0.2f))
                            TextButton(onClick = action, modifier = Modifier.weight(1f)) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Icon(icon, contentDescription = label, tint = Color.White.copy(alpha = 0.85f), modifier = Modifier.size(16.dp))
                                    Text(label, color = Color.White.copy(alpha = 0.85f), fontSize = 10.sp, fontWeight = FontWeight.Medium)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun LoadingCard(slot: ComplimentSlot) {
    val alpha by rememberInfiniteTransition(label = "pulse").animateFloat(
        initialValue = 0.7f, targetValue = 1f, animationSpec = infiniteRepeatable(
            tween(1000), RepeatMode.Reverse
        ), label = "alpha"
    )
    Card(modifier = Modifier.fillMaxWidth().height(110.dp), shape = RoundedCornerShape(20.dp)) {
        Box(modifier = Modifier.background(slotGradient(slot)).fillMaxSize(), contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(28.dp), strokeWidth = 2.dp)
                Spacer(Modifier.height(10.dp))
                Text("Δημιουργώ το μήνυμά σου...", color = Color.White.copy(alpha = alpha), fontSize = 13.sp)
            }
        }
    }
}

@Composable
fun LockedSlotCard(slot: ComplimentSlot, isAvailable: Boolean, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable(enabled = isAvailable, onClick = onClick),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
            Text(slot.emoji, fontSize = 26.sp)
            Column(modifier = Modifier.weight(1f)) {
                Text(slot.displayName, fontWeight = FontWeight.Bold, color = if (isAvailable) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurfaceVariant)
                Text(if (isAvailable) "Πάτα για το μήνυμά σου" else "Διαθέσιμο στις ${slot.hour}:00",
                    fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Icon(if (isAvailable) Icons.Filled.AutoAwesome else Icons.Filled.Lock,
                contentDescription = null,
                tint = if (isAvailable) Purple40 else MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(20.dp))
        }
    }
}

@Composable
fun StreakBanner(current: Int, longest: Int, total: Int, streakRepo: com.gkatidis.daymaker.services.StreakRepository? = null) {
    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(16.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(streakRepo?.streakEmoji(current) ?: "🔥", fontSize = 22.sp)
                    Text("$current", fontSize = 28.sp, fontWeight = FontWeight.Bold)
                    Text(if (current == 1) "μέρα" else "μέρες", fontSize = 14.sp, color = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.padding(bottom = 2.dp))
                }
                Text(streakRepo?.streakMessage(current) ?: "Συνέχισε!", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Column(horizontalAlignment = Alignment.End) {
                Text("$total", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Purple40)
                Text("σύνολο", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}

@Composable
fun DayScoreRing(score: Int, breakdown: Map<String, Pair<Boolean, Int>>) {
    val animated by animateFloatAsState(score / 100f, animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy), label = "score")
    val color = when {
        score < 30 -> Color(0xFFF44336)
        score < 60 -> Color(0xFFFF9800)
        score < 90 -> Color(0xFF2196F3)
        else -> Color(0xFF4CAF50)
    }
    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(16.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(20.dp)) {
            Box(modifier = Modifier.size(70.dp), contentAlignment = Alignment.Center) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    drawArc(color = color.copy(alpha = 0.15f), startAngle = -90f, sweepAngle = 360f, useCenter = false, style = Stroke(10f, cap = StrokeCap.Round))
                    drawArc(color = color, startAngle = -90f, sweepAngle = 360f * animated, useCenter = false, style = Stroke(10f, cap = StrokeCap.Round))
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("$score", fontWeight = FontWeight.Bold, fontSize = 20.sp, color = color)
                    Text("/100", fontSize = 9.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text("Σκορ σήμερα", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                breakdown.forEach { (label, data) ->
                    val (done, pts) = data
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(if (done) Icons.Filled.CheckCircle else Icons.Filled.RadioButtonUnchecked, null,
                            tint = if (done) Color(0xFF4CAF50) else MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.size(12.dp))
                        Text(label, fontSize = 11.sp, color = if (done) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.weight(1f))
                        Text("+$pts", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = if (done) Color(0xFF4CAF50) else MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }
    }
}

@Composable
fun MoodCheckIn(onMoodSelected: (MoodState) -> Unit) {
    var selected by remember { mutableStateOf<MoodState?>(null) }
    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(20.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text("Πώς νιώθεις σήμερα;", fontWeight = FontWeight.Bold)
                Text("Θα προσαρμόσω το μήνυμά σου αναλόγως.", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                MoodState.values().forEach { mood ->
                    val isSelected = selected == mood
                    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (isSelected) Purple40.copy(alpha = 0.12f) else Color.Transparent)
                        .border(if (isSelected) BorderStroke(1.5.dp, Purple40) else BorderStroke(0.dp, Color.Transparent), RoundedCornerShape(12.dp))
                        .clickable {
                            selected = mood
                            onMoodSelected(mood)
                        }
                        .padding(8.dp)
                    ) {
                        Text(mood.emoji, fontSize = if (isSelected) 30.sp else 24.sp)
                        Text(mood.label, fontSize = 9.sp, textAlign = TextAlign.Center, color = if (isSelected) Purple40 else MaterialTheme.colorScheme.onSurfaceVariant, fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal)
                    }
                }
            }
        }
    }
}

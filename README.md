# ☀️ DayMaker

> Η εφαρμογή που φτιάχνει τη μέρα σου.

**© 2026 Konstantinos Gkatidis. All rights reserved.**

---

## Τι είναι το DayMaker

Το DayMaker κάνει μια αναλυτική συνέντευξη κατά το setup, μαθαίνει ποιος είσαι — και μετά, 4 φορές την ημέρα, σου στέλνει εξατομικευμένα, ρεαλιστικά και κολακευτικά μηνύματα, δημιουργημένα από Claude AI ειδικά για σένα.

## Features

- 🎤 **14-ερωτήσεις onboarding** — conversational interview
- ☀️ **4 εξατομικευμένα μηνύματα/μέρα** (8:00, 11:00, 15:00, 20:00)
- 😊 **Daily mood check-in** — τα μηνύματα προσαρμόζονται
- ⚡️ **Instant Boost** — on-demand κομπλιμέντο (3/ημέρα)
- ❤️ **Favorites Vault** — αποθήκευσε τα αγαπημένα σου
- ✍️ **Journal** — γράψε πώς σε έκανε να νιώσεις
- 🔥 **Streak system** — consecutive days tracking
- 🏅 **Daily Score** (0-100) — gamification
- 🔊 **Voice reading** — άκουσε το μήνυμα
- 📤 **Share cards** — κοινοποίησε στα social
- ✉️ **Soul Letter** — κάθε Κυριακή, βαθύτερη επιστολή
- 🗓️ **Monthly Growth Letter** — κάθε 1η του μήνα
- ✨ **Typewriter animation** — τα μηνύματα γράφονται μπροστά σου
- 🌟 **Particle background** — premium feel

## Platforms

| Platform | Framework | Folder |
|----------|-----------|--------|
| iOS 16+ | SwiftUI | `DayMaker/` |
| Android 8+ | Jetpack Compose | `DayMakerAndroid/` |

## Setup

### iOS
1. Άνοιξε `DayMaker.xcodeproj` στο Xcode 14.2+
2. Signing & Capabilities → βάλε το Apple ID σου
3. `Cmd + R`

### Android
1. Άνοιξε τον φάκελο `DayMakerAndroid/` στο Android Studio
2. Sync Gradle
3. Run

### Claude API Key
Και οι δύο εφαρμογές χρειάζονται Claude API key:
- Πήγαινε στο **console.anthropic.com**
- API Keys → Create Key
- Βάλε το key στις Ρυθμίσεις της εφαρμογής

## Tech Stack

**iOS:** SwiftUI · UserNotifications · AVSpeechSynthesizer · Claude API  
**Android:** Jetpack Compose · WorkManager · TextToSpeech · DataStore · OkHttp · Claude API

---

*Powered by [Claude AI](https://anthropic.com) · Made with ❤️*

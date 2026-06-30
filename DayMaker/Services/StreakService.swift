// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import Foundation

final class StreakService: ObservableObject {
    static let shared = StreakService()

    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalDays: Int = 0

    private let streakKey = "daymaker_streak_current"
    private let longestKey = "daymaker_streak_longest"
    private let lastOpenKey = "daymaker_last_open"
    private let totalKey = "daymaker_total_days"

    private init() {
        load()
        checkStreak()
    }

    func recordToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastOpen = UserDefaults.standard.object(forKey: lastOpenKey) as? Date

        if let last = lastOpen {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay == today { return }

            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        totalDays += 1
        if currentStreak > longestStreak { longestStreak = currentStreak }
        UserDefaults.standard.set(today, forKey: lastOpenKey)
        save()
    }

    private func checkStreak() {
        guard let last = UserDefaults.standard.object(forKey: lastOpenKey) as? Date else { return }
        let lastDay = Calendar.current.startOfDay(for: last)
        let today = Calendar.current.startOfDay(for: Date())
        let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
        if diff > 1 {
            currentStreak = 0
            save()
        }
    }

    private func save() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestKey)
        UserDefaults.standard.set(totalDays, forKey: totalKey)
    }

    private func load() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestKey)
        totalDays = UserDefaults.standard.integer(forKey: totalKey)
    }

    func reset() {
        currentStreak = 0
        longestStreak = 0
        totalDays = 0
        UserDefaults.standard.removeObject(forKey: streakKey)
        UserDefaults.standard.removeObject(forKey: longestKey)
        UserDefaults.standard.removeObject(forKey: lastOpenKey)
        UserDefaults.standard.removeObject(forKey: totalKey)
    }

    var streakEmoji: String {
        switch currentStreak {
        case 0: return "✨"
        case 1..<4: return "🔥"
        case 4..<8: return "🔥🔥"
        case 8..<15: return "⚡️🔥"
        default: return "🏆🔥"
        }
    }

    var streakMessage: String {
        switch currentStreak {
        case 0: return "Ξεκίνα σήμερα!"
        case 1: return "Ξεκίνησες!"
        case 2..<5: return "\(currentStreak) μέρες στη σειρά"
        case 5..<10: return "\(currentStreak) μέρες — συνέχισε!"
        case 10..<30: return "\(currentStreak) μέρες — απίστευτο!"
        default: return "\(currentStreak) μέρες — θρυλικός!"
        }
    }
}

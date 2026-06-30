// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import Foundation

final class ProfileService: ObservableObject {
    static let shared = ProfileService()

    @Published var profile: UserProfile = UserProfile()
    @Published var compliments: [Compliment] = []
    @Published var todayMood: MoodState? = nil

    private let profileKey = "daymaker_profile"
    private let complimentsKey = "daymaker_compliments"
    private let moodKey = "daymaker_today_mood"
    private let moodDateKey = "daymaker_mood_date"

    private init() {
        loadProfile()
        loadCompliments()
        loadTodayMood()
    }

    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    private func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let saved = try? JSONDecoder().decode(UserProfile.self, from: data) else { return }
        self.profile = saved
    }

    func saveCompliment(_ compliment: Compliment) {
        compliments.insert(compliment, at: 0)
        persistCompliments()
    }

    func updateCompliment(_ compliment: Compliment) {
        if let idx = compliments.firstIndex(where: { $0.id == compliment.id }) {
            compliments[idx] = compliment
            persistCompliments()
        }
    }

    func markComplimentRead(id: UUID) {
        if let idx = compliments.firstIndex(where: { $0.id == id }) {
            compliments[idx].isRead = true
            persistCompliments()
        }
    }

    func saveJournalNote(for id: UUID, note: String) {
        if let idx = compliments.firstIndex(where: { $0.id == id }) {
            compliments[idx].journalNote = note
            persistCompliments()
            NotificationCenter.default.post(name: .scoreNeedsUpdate, object: nil)
        }
    }

    func toggleFavorite(id: UUID) {
        if let idx = compliments.firstIndex(where: { $0.id == id }) {
            compliments[idx].isFavorite.toggle()
            let isFav = compliments[idx].isFavorite
            persistCompliments()
            HapticService.impact(isFav ? .heavy : .light)
        }
    }

    var favoriteCompliments: [Compliment] {
        compliments.filter { $0.isFavorite }
    }

    var isFirstOfMonth: Bool {
        Calendar.current.component(.day, from: Date()) == 1
    }

    var todaysMonthlyLetter: Compliment? {
        todaysCompliments.first { $0.isMonthlyLetter }
    }

    private func persistCompliments() {
        if let data = try? JSONEncoder().encode(compliments) {
            UserDefaults.standard.set(data, forKey: complimentsKey)
        }
    }

    private func loadCompliments() {
        guard let data = UserDefaults.standard.data(forKey: complimentsKey),
              let saved = try? JSONDecoder().decode([Compliment].self, from: data) else { return }
        self.compliments = saved
    }

    func saveTodayMood(_ mood: MoodState) {
        self.todayMood = mood
        UserDefaults.standard.set(mood.rawValue, forKey: moodKey)
        UserDefaults.standard.set(Date(), forKey: moodDateKey)
    }

    private func loadTodayMood() {
        guard let date = UserDefaults.standard.object(forKey: moodDateKey) as? Date,
              Calendar.current.isDateInToday(date) else { return }
        let raw = UserDefaults.standard.integer(forKey: moodKey)
        todayMood = MoodState(rawValue: raw)
    }

    func resetAll() {
        profile = UserProfile()
        compliments = []
        todayMood = nil
        [profileKey, complimentsKey, moodKey, moodDateKey].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        StreakService.shared.reset()
    }

    var todaysCompliments: [Compliment] {
        let cal = Calendar.current
        return compliments.filter { cal.isDateInToday($0.date) }
    }

    var unreadCount: Int {
        compliments.filter { !$0.isRead }.count
    }

    var isSunday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 1
    }
}

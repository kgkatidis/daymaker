// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import UserNotifications
import Foundation

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleDaily(for profile: UserProfile) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for slot in ComplimentSlot.allCases {
            scheduleSlot(slot, userName: profile.name, center: center)
        }
    }

    private func scheduleSlot(_ slot: ComplimentSlot, userName: String, center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "\(slot.emoji) \(slot.displayName)"
        content.body = notificationBody(for: slot, name: userName)
        content.sound = .default
        content.badge = 1
        content.userInfo = ["slot": slot.rawValue]

        var components = DateComponents()
        components.hour = slot.hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let id = "daymaker_slot_\(slot.rawValue)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    private func notificationBody(for slot: ComplimentSlot, name: String) -> String {
        let n = name.isEmpty ? "σε" : name
        switch slot {
        case .morning: return "Καλημέρα \(n)! Ένα μήνυμα ειδικά για σένα σε περιμένει ✨"
        case .midMorning: return "Μια στιγμή γεμάτη θετική ενέργεια για τον \(n) 🌟"
        case .afternoon: return "Θυμίσου ποιος είσαι, \(n). Άνοιξε να δεις 💫"
        case .evening: return "Πριν τελειώσει η μέρα — ένα μήνυμα μόνο για σένα 🌙"
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}

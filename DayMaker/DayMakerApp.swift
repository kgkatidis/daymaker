// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI
import UserNotifications

@main
struct DayMakerApp: App {
    @StateObject private var profileService = ProfileService.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(profileService)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
